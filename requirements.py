def read_poetry_lock():
    import toml
    with open('./poetry.lock') as f:
        toml_string = f.read()
    return toml.loads(toml_string)


data = read_poetry_lock()

lines = []
for pkg in data["package"]:
    if pkg["category"] == "main":
        line = "==".join((pkg["name"], pkg["version"]))
        lines.append(line)

for line in lines:
    print(line)
