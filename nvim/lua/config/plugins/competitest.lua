return {
	{
    'xeluxee/competitest.nvim',
    dependencies = 'MunifTanjim/nui.nvim',
    cmd = {"CompetiTest"},
    keys = {
      { "<leader>cc" , "<cmd>CompetiTest run<cr>", desc = "CompetiTest run"},
    },
    config = function() require('competitest').setup({
      popup_ui = {
	total_width = 1,
	total_height = 1,
      },
      runner_ui = {
	viewer = {
	  width = 1,
	  height = 1,
	},
      },
      received_problems_path = "$(CWD)/$(JAVA_TASK_CLASS).$(FEXT)",
      received_contests_problems_path = "$(JAVA_TASK_CLASS).$(FEXT)",
      compile_command = {
	cpp = { exec = "g++", args = { "-Wall", "-Wextra", "-std=c++17", 
	                               "-ggdb", "-fsanitize=address,undefined", 
	                               "$(FNAME)", "-o", "$(FNOEXT)" } },
      },
    }) end,
	} 
}
