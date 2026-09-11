# Questionário de Construção de Containers e Reprodutibilidade

Dataset analisado:

1. Qual a diferença entre um container e uma máquina virtual? E de container para ambiente conda?

Resposta: Um container é isolado e mais leve do que uma máquina virtual

2. Por que usamos Singularity/Apptainer em cluster e não Docker?

Resposta: Porque o docker precisa de sudo obrigatoriamente, e tem vairas camadas

3. Para que serve cada uma das seções %post, %environment e %runscript em uma definition file?

Resposta: %post para configurar o ambiente, %enviroment para definir variaveis de ambiente para quando o container for executado, %runscript é para rodar as operações

4. O que é um bind mount e por que ele é necessário?

Resposta: é um mecanismo que permite disponibilizar dentro do diretorio um arquivo que esta fora dele, ele é necessário porque o container é isolado do sistema de arquivos externo.

5. Como o uso de containers contribui para a reprodutibilidade de uma análise?

Resposta: Permite empacotar as bibliotecas, dependencias, etc num pacote só, para deixar tudo organizaado.
