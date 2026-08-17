local M = {}

local function get_package_root()
	local tsserver = vim.fn.exepath("tsserver")
	if tsserver == "" then
		return nil
	end

	local real_tsserver = vim.uv.fs_realpath(tsserver)
	if not real_tsserver then
		return nil
	end

	return vim.fn.fnamemodify(real_tsserver, ":h:h")
end

function M.get_tsdk()
	local local_tsdk = vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "typescript", "lib")
	if vim.uv.fs_stat(local_tsdk) then
		return local_tsdk
	end

	local package_root = get_package_root()
	if package_root then
		return vim.fs.joinpath(package_root, "lib", "node_modules", "typescript", "lib")
	end

	return local_tsdk
end

function M.get_node_path()
	local paths = {}
	local local_node_modules = vim.fs.joinpath(vim.fn.getcwd(), "node_modules")
	if vim.uv.fs_stat(local_node_modules) then
		table.insert(paths, local_node_modules)
	end

	local package_root = get_package_root()
	if package_root then
		table.insert(paths, vim.fs.joinpath(package_root, "lib", "node_modules"))
	end

	if vim.env.NODE_PATH and vim.env.NODE_PATH ~= "" then
		table.insert(paths, vim.env.NODE_PATH)
	end

	return table.concat(paths, ":")
end

return M
