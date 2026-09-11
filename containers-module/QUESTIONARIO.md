# Questionário de Construção de Containers e Reprodutibilidade

Dataset analisado:

1. Qual a diferença entre um container e uma máquina virtual? E de container para ambiente conda?

Resposta: Containers compartilham de recursos do kernel do host, enquanto a máquina virtual compartilha dos recursos fisícos hostiando. Diferente do conda o container contem não só o ambiente mas o sistemas e todos as funcionalidade necessárias para executar a aplicação conteinerizada.

2. Por que usamos Singularity/Apptainer em cluster e não Docker?

Resposta: Por que o docker necessita de permissão sudo para executar os containers

3. Para que serve cada uma das seções %post, %environment e %runscript em uma definition file?

Resposta: % post serve para executar comando durante o build, %environment serve para exportar e compartilhar variáveis de ambiente em tempo de execução, %runscrip serve para você rodar comando quando usar o comando Singularity run ...

4. O que é um bind mount e por que ele é necessário?

Resposta: Bind mount é um comando do singularity que permite linkar um diretório do host com um diretório do container e isso é necessário para permit persistem de dados gerados ou modificados dentro do container.

5. Como o uso de containers contribui para a reprodutibilidade de uma análise?

Resposta: Com o container você consegue compartilhar o código, ambiente e ferramentas necessárias para reproduzir os dados gerados em suas análises permitindo a reprodutibilidade independente do sistema operacional.
