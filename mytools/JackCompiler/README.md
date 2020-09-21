Test tokenizer
```bash
# In julia container
docker-compose run julia bash
cd /home/julia/mytools/JackCompiler
julia --project=.

using JackCompiler
# Generate XML file. Main.jack -> MyMainT.xml
function writefile(path)
    x = read(open(path), String)
    l = JackCompiler.tokenize(x)
    open(joinpath(dirname(path), "My" * basename(path)[1:end-5] * "T.xml"), "w") do fp
        JackCompiler.dump(fp, l)
    end
end

path = "/home/julia/projects/10/ExpressionLessSquare/Main.jack"
writefile(path)
path = "/home/julia/projects/10/ExpressionLessSquare/Square.jack"
writefile(path)
path = "/home/julia/projects/10/ExpressionLessSquare/SquareGame.jack"
writefile(path)

path = "/home/julia/projects/10/Square/Main.jack"
writefile(path)
path = "/home/julia/projects/10/Square/Square.jack"
writefile(path)
path = "/home/julia/projects/10/Square/SquareGame.jack"
writefile(path)

path = "/home/julia/projects/10/ArrayTest/Main.jack"
writefile(path)
```


```bash
# In ubuntu container
docker-compose run ubuntu bash
cd ~/projects/10/ExpressionLessSquare/
bash ~/tools/TextComparer.sh MainT.xml MyMainT.xml
bash ~/tools/TextComparer.sh SquareT.xml MySquareT.xml
bash ~/tools/TextComparer.sh SquareGameT.xml MySquareGameT.xml

cd ~/projects/10/Square
bash ~/tools/TextComparer.sh MainT.xml MyMainT.xml
bash ~/tools/TextComparer.sh SquareT.xml MySquareT.xml
bash ~/tools/TextComparer.sh SquareGameT.xml MySquareGameT.xml

cd ~/projects/10/ArrayTest
bash ~/tools/TextComparer.sh MainT.xml MyMainT.xml
```


Test parser
```
docker-compose run julia bash
cd /home/julia/mytools/JackCompiler
julia --project=.
julia> JackCompiler.genxml("/home/julia/projects/10/ExpressionLessSquare/")
julia> JackCompiler.genxml("/home/julia/projects/10/Square/")
julia> JackCompiler.genxml("/home/julia/projects/10/ArrayTest/")



docker-compose run ubuntu bash
cd /home/ubuntu/projects/10/ExpressionLessSquare
bash ~/tools/TextComparer.sh Main.xml MainMy.xml
bash ~/tools/TextComparer.sh Square.xml SquareMy.xml
bash ~/tools/TextComparer.sh SquareGame.xml SquareGameMy.xml

cd /home/ubuntu/projects/10/Square
bash ~/tools/TextComparer.sh Main.xml MainMy.xml
bash ~/tools/TextComparer.sh Square.xml SquareMy.xml
bash ~/tools/TextComparer.sh SquareGame.xml SquareGameMy.xml

cd /home/ubuntu/projects/10/ArrayTest
bash ~/tools/TextComparer.sh Main.xml MainMy.xml
```
