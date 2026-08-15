local M = {}

M.folders = {}
M.options = {
    exclude_dirs = { ".git", "node_modules" },
    integrations = {
        fzf = true,
        mini_files = true,
        auto_session = true,
    },
}

local bookmark_ids = "123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local list_contains = vim.list_contains or vim.tbl_contains

-- Helpers

local function require_integration(module_name, integration_name)
    local ok, module = pcall(require, module_name)
    if not ok then
        vim.notify(
            ("workspace: %s integration is enabled, but %s could not be loaded"):format(
                integration_name,
                module_name
            ),
            vim.log.levels.ERROR
        )
        return nil
    end

    return module
end

local function normalize(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end

    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

-- Workspace

function M.get_paths()
    local paths = {}
    local seen = {}

    local function add(path)
        path = normalize(path)
        if path and not seen[path] and vim.fn.isdirectory(path) == 1 then
            seen[path] = true
            table.insert(paths, path)
        end
    end

    add(vim.fn.getcwd())
    for _, path in ipairs(M.folders) do
        add(path)
    end

    return paths
end

function M.get_roots()
    local roots = {}
    local used_names = {}

    for _, path in ipairs(M.get_paths()) do
        local base = vim.fs.basename(path)
        if base == nil or base == "" then
            base = "root"
        end

        local name = base
        local suffix = 2
        while used_names[name] do
            name = base .. "-" .. suffix
            suffix = suffix + 1
        end

        used_names[name] = true
        table.insert(roots, { name = name, path = path })
    end

    return roots
end

function M.add(path)
    path = normalize(path)
    if not path or vim.fn.isdirectory(path) ~= 1 then
        return false, "not_directory"
    end

    if list_contains(M.get_paths(), path) then
        return false, "duplicate"
    end

    table.insert(M.folders, path)
    return true, path
end

function M.remove(path)
    path = normalize(path)
    for i, folder in ipairs(M.folders) do
        if normalize(folder) == path then
            table.remove(M.folders, i)
            return true, path
        end
    end

    return false
end

-- Commands

local function add_and_notify(path)
    local added, result = M.add(path)
    if not added then
        local message = result == "duplicate"
            and "Already in workspace: " .. path
            or "Not a directory: " .. path
        vim.notify(message, vim.log.levels.INFO)
        return
    end

    vim.notify("Added folder to workspace: " .. result)
end

local function remove_and_notify(path)
    if normalize(path) == normalize(vim.fn.getcwd()) then
        vim.notify("Cannot remove the current working directory from the workspace", vim.log.levels.INFO)
        return
    end

    local removed, normalized_path = M.remove(path)
    if removed then
        vim.notify("Removed from workspace: " .. normalized_path)
    else
        vim.notify("Folder is not in the workspace: " .. path, vim.log.levels.INFO)
    end
end

local function setup_commands()
    vim.api.nvim_create_user_command("WorkspaceAdd", function(args)
        add_and_notify(args.args)
    end, {
        nargs = 1,
        complete = "dir",
        desc = "Add a folder to the workspace",
        force = true,
    })

    vim.api.nvim_create_user_command("WorkspaceRemove", function(args)
        remove_and_notify(args.args)
    end, {
        nargs = 1,
        complete = function(arg_lead)
            return vim.tbl_filter(function(path)
                return vim.startswith(path, arg_lead)
            end, M.folders)
        end,
        desc = "Remove a folder from the workspace",
        force = true,
    })

    vim.api.nvim_create_user_command("WorkspaceList", function()
        local lines = { normalize(vim.fn.getcwd()) .. " (cwd)" }
        vim.list_extend(lines, M.folders)
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
            title = "Workspace folders",
        })
    end, {
        desc = "List workspace folders",
        force = true,
    })
end

-- fzf-lua integration

local function fd_excludes()
    return table.concat(vim.tbl_map(function(dir)
        return "--exclude " .. vim.fn.shellescape(dir)
    end, M.options.exclude_dirs), " ")
end

local function rg_excludes()
    return table.concat(vim.tbl_map(function(dir)
        return "--glob " .. vim.fn.shellescape("!" .. dir)
    end, M.options.exclude_dirs), " ")
end

local function workspace_formatter_source()
    local roots = M.get_roots()
    table.sort(roots, function(a, b)
        return #a.path > #b.path
    end)

    local source = {
        "return function(path)",
        "    local roots = {",
    }
    for _, root in ipairs(roots) do
        table.insert(source, string.format(
            "        { path = %q, name = %q },",
            root.path,
            root.name
        ))
    end
    vim.list_extend(source, {
        "    }",
        "    for _, root in ipairs(roots) do",
        "        local prefix = root.path == '/' and '/' or root.path .. '/'",
        "        if path == root.path then",
        "            return root.name",
        "        elseif path:sub(1, #prefix) == prefix then",
        "            local relative = path:sub(#prefix + 1):gsub('^%./', '')",
        "            return root.name .. '/' .. relative",
        "        end",
        "    end",
        "    return path",
        "end",
    })
    return table.concat(source, "\n")
end

local function restore_workspace_path(entry)
    local utils = require_integration("fzf-lua.utils", "fzf-lua")
    if not utils then
        return entry
    end

    local parts = utils.strsplit(entry, utils.nbsp)
    local path = parts[#parts]

    for _, root in ipairs(M.get_roots()) do
        local prefix = root.name .. "/"
        if path == root.name then
            parts[#parts] = root.path
            break
        elseif path:sub(1, #prefix) == prefix then
            local relative = path:sub(#prefix + 1)
            parts[#parts] = root.path == "/" and "/" .. relative or root.path .. "/" .. relative
            break
        end
    end

    return table.concat(parts, utils.nbsp)
end

function M.add_folder()
    local fzf = require_integration("fzf-lua", "fzf-lua")
    if not fzf then
        return
    end

    local command = "fd --type d --absolute-path --hidden " .. fd_excludes()
        .. " . " .. vim.fn.shellescape("/")

    fzf.fzf_exec(command, {
        prompt = "Add folder to workspace> ",
        actions = {
            ["default"] = function(selected)
                add_and_notify(selected[1])
            end,
        },
    })
end

function M.remove_folder()
    local fzf = require_integration("fzf-lua", "fzf-lua")
    if not fzf then
        return
    end

    fzf.fzf_exec(M.get_paths(), {
        prompt = "Remove folder from workspace> ",
        actions = {
            ["default"] = function(selected)
                remove_and_notify(selected[1])
            end,
        },
    })
end

function M.find_files()
    local fzf = require_integration("fzf-lua", "fzf-lua")
    if not fzf then
        return
    end

    local paths = M.get_paths()
    local has_extra = #paths > 1
    fzf.files({
        search_paths = paths,
        formatter = "path.workspace",
        absolute_path = true,
        cwd_prompt = not has_extra,
        cwd_header = not has_extra,
        prompt = has_extra and "Files> " or nil,
        fd_opts = "--color=never --hidden --follow --type f --type l " .. fd_excludes(),
    })
end

function M.live_grep()
    local fzf = require_integration("fzf-lua", "fzf-lua")
    if not fzf then
        return
    end

    local paths = M.get_paths()
    local has_extra = #paths > 1
    fzf.live_grep({
        search_paths = paths,
        formatter = "path.workspace",
        absolute_path = true,
        cwd_header = not has_extra,
        resume = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --follow "
            .. rg_excludes(),
    })
end

local function setup_fzf()
    local fzf = require_integration("fzf-lua", "fzf-lua")
    if not fzf then
        return
    end

    fzf.setup({
        formatters = {
            path = {
                workspace = {
                    _to = workspace_formatter_source,
                    from = restore_workspace_path,
                },
            },
        },
    }, true)

    local map = vim.keymap.set
    map("n", "<leader>fw", M.add_folder, { desc = "Add folder to workspace" })
    map("n", "<leader>fwx", M.remove_folder, { desc = "Remove folder from workspace" })
    map("n", "<leader>ff", M.find_files, { desc = "Fzf workspace files" })
    map("n", "<leader>fs", M.live_grep, { desc = "Fzf live grep workspace" })
end

-- mini.files integration

function M.toggle_explorer()
    local files = require_integration("mini.files", "mini.files")
    if not files then
        return
    end

    if not files.close() then
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" or vim.uv.fs_stat(path) == nil then
            path = vim.fn.getcwd()
        end
        files.open(path)
    end
end

local function setup_mini_files()
    local files = require_integration("mini.files", "mini.files")
    if not files then
        return
    end

    vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("WorkspaceMiniFiles", { clear = true }),
        pattern = "MiniFilesExplorerOpen",
        callback = function()
            for i, path in ipairs(M.get_paths()) do
                local id = bookmark_ids:sub(i, i)
                if id == "" then
                    break
                end

                local suffix = i == 1 and " (cwd)" or ""
                files.set_bookmark(id, path, {
                    desc = "Workspace" .. suffix .. ": " .. path,
                })
            end
        end,
    })

    vim.keymap.set("n", "<leader>e", M.toggle_explorer, {
        desc = "Open file explorer (workspace roots: '1, '2, ...)",
    })
end

-- auto-session integration

local function setup_auto_session()
    local config = require_integration("auto-session.config", "auto-session")
    if not config then
        return
    end

    local previous_save = config.save_extra_data
    local previous_restore = config.restore_extra_data

    config.save_extra_data = function(session_name)
        local payload = {
            workspace_version = 1,
            workspace_folders = M.folders,
        }
        if previous_save then
            payload.previous_extra_data = previous_save(session_name)
        end
        return vim.json.encode(payload)
    end

    config.restore_extra_data = function(session_name, extra_data)
        local decoded, data = pcall(vim.json.decode, extra_data)
        local is_workspace_data = decoded
            and type(data) == "table"
            and type(data.workspace_folders) == "table"

        if not is_workspace_data then
            if previous_restore then
                previous_restore(session_name, extra_data)
            end
            return
        end

        if data.workspace_version == 1
            and previous_restore
            and data.previous_extra_data ~= nil
        then
            previous_restore(session_name, data.previous_extra_data)
        end

        M.folders = data.workspace_folders
    end
end

-- Setup

function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.options, opts or {})

    setup_commands()
    if M.options.integrations.fzf then
        setup_fzf()
    end
    if M.options.integrations.mini_files then
        setup_mini_files()
    end
    if M.options.integrations.auto_session then
        setup_auto_session()
    end
end

return M
