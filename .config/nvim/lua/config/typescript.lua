local M = {}

local function get_local_tsdk()
	return vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "typescript", "lib")
end

function M.get_tsdk()
	local local_tsdk = get_local_tsdk()
	if vim.uv.fs_stat(local_tsdk) then
		return local_tsdk
	end

	if vim.env.TYPESCRIPT_SDK and vim.uv.fs_stat(vim.env.TYPESCRIPT_SDK) then
		return vim.env.TYPESCRIPT_SDK
	end

	return nil
end

function M.get_node_path()
	local paths = {}
	local local_node_modules = vim.fs.joinpath(vim.fn.getcwd(), "node_modules")
	if vim.uv.fs_stat(local_node_modules) then
		table.insert(paths, local_node_modules)
	end

	local tsdk = M.get_tsdk()
	if tsdk then
		table.insert(paths, vim.fn.fnamemodify(tsdk, ":h:h"))
	end

	if vim.env.NODE_PATH and vim.env.NODE_PATH ~= "" then
		table.insert(paths, vim.env.NODE_PATH)
	end

	return table.concat(paths, ":")
end

return M
