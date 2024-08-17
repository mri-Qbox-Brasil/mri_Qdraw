function Load()
    local File = LoadResourceFile(GetCurrentResourceName(), "./data.json")
    return (json.decode(File))
end

function Save(File)
    SaveResourceFile(GetCurrentResourceName(), "data.json", json.encode(File), -1)
end