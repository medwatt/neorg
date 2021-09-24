return function(module)
    return {
        -- FIXME: Still errors in multiple flags selection
        public = {
            show_quick_actions = function(configs)
                -- Generate quick_actions selection popup
                local buffer = module.required["core.ui"].create_split("Quick Actions")
                local selection = module.required["core.ui"].begin_selection(buffer):listener(
                    "destroy",
                    { "<Esc>" },
                    function(self)
                        self:destroy()
                    end
                )

                selection = selection
                    :title("Quick Actions")
                    :blank()
                    :text("Capture")
                    :concat(module.private.add_to_inbox)
                    :blank()
                    :text("Displays")
                    :concat(function(_selection)
                        return module.private.generate_display_flags(_selection, configs)
                    end)

                selection = selection:blank():flag("x", "Debug Mode", function()
                    local nodes = module.required["core.gtd.queries"].get("tasks", { filename = "index.norg" })
                    module.required["core.gtd.queries"].generate_missing_uuids(nodes, "tasks")
                end)
            end,

            edit_task = function(task)
                -- Add metadatas to task node
                local task_extracted = module.required["core.gtd.queries"].add_metadata({ task }, "task")[1]
                local task_not_extracted = module.required["core.gtd.queries"].add_metadata(
                    { task },
                    "task",
                    { extract = false }
                )[1]

                local modified = {}

                -- Create selection popup
                local buffer = module.required["core.ui"].create_split("Edit Task")
                local selection = module.required["core.ui"].begin_selection(buffer)
                selection = selection:listener("destroy", { "<Esc>" }, function(self)
                    self:destroy()
                end)

                -- TODO: Make the content prettier
                selection = selection
                    :title("Edit Task")
                    :blank()
                    :concat(function(_selection)
                        return module.private.edit(
                            _selection,
                            "e",
                            "Edit content: " .. task_extracted.content,
                            "content",
                            modified,
                            { prompt_title = "Edit Content" }
                        )
                    end)

                selection = selection:blank():blank():flag("<CR>", "Validate", function()
                    task_not_extracted = module.required["core.gtd.queries"].modify(task_not_extracted, "task", "content", modified.content)

                    vim.api.nvim_buf_call(task_not_extracted.bufnr, function()
                        vim.cmd(" write ")
                    end)
                end)
            end,
        },
    }
end
