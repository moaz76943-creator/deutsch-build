with open("tools/daily_evolution/engine.py", "r") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if line.strip() == "self.state[\"task_matrix\"][task_id] = t_dict":
        new_lines.append("                self.state[\"task_matrix\"][task_id] = t_dict\n")
        new_lines.append("                if status == \"READY\":\n")
        new_lines.append("                    tasks_to_return.append(Task.from_dict(t_dict))\n")
    elif line.strip() == "tasks_to_return.append(Task.from_dict(t_dict))":
        pass
    elif line.strip() == "while len(tasks_to_return) < self.max_parallel and checked < len(LANGUAGES):":
        new_lines.append("        # Find up to max_parallel new READY tasks\n")
        new_lines.append("        while len([t for t in tasks_to_return if t.status == 'READY']) < self.max_parallel and checked < len(LANGUAGES):\n")
    else:
        new_lines.append(line)

with open("tools/daily_evolution/engine.py", "w") as f:
    f.writelines(new_lines)
