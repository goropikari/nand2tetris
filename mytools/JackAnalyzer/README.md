Test tokenizer
```bash
# In julia container
docker-compose run julia bash
cd /home/julia/mytools/JackAnalyzer
julia --project=.

using JackAnalyzer
# Generate XML file. Main.jack -> MyMainT.xml
function writefile(path)
    x = read(open(path), String)
    l = JackAnalyzer.tokenize(x)
    open(joinpath(dirname(path), "My" * basename(path)[1:end-5] * "T.xml"), "w") do fp
        JackAnalyzer.dump(fp, l)
    end
end

path = "/home/julia/projects/10/ExpressionLessSquare/Main.jack"
writefile(path)

path = "/home/julia/projects/10/ExpressionLessSquare/Square.jack"
writefile(path)

path = "/home/julia/projects/10/ExpressionLessSquare/SquareGame.jack"
writefile(path)
```


```bash
# In ubuntu container
docker-compose run ubuntu bash
bash ~/tools/TextComparer.sh MainT.xml MyMainT.xml
bash ~/tools/TextComparer.sh SquareT.xml MySquareT.xml
bash ~/tools/TextComparer.sh SquareGameT.xml MySquareGameT.xml
```