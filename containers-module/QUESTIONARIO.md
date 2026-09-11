# Questionário de Construção de Containers e Reprodutibilidade

Dataset analisado: 16S\_Hydrochoerus\_hydrochaeris


1. Qual a diferença entre um container e uma máquina virtual? E de container para ambiente conda?

Resposta: Máquina virtual é mais pesada (SO completo), consome mais recurso no PC e tem o boot mais lento. Container usa o SO do host, leve, portátil e de fácil compartilhamento.


2. Por que usamos Singularity/Apptainer em cluster e não Docker?

Resposta: Feito para HPC, não é necessário acesso root como no Docker para rodar.


3. Para que serve cada uma das seções %post, %environment e %runscript em uma definition file?

Resposta: 

%post: executar as instalações dos pacotes/programas 

&#x20;

%environment: Variáveis de ambiente definidas em tempo de execução.

&#x20;

%runscript: O que roda ao chamar singularity run


4. O que é um bind mount e por que ele é necessário?

Resposta: É a montagem de uma pasta do host em um caminho dentro do container. Ele é necessário para conectarmos nossos dados ao container de execução.


5. Como o uso de containers contribui para a reprodutibilidade de uma análise?

Resposta: Um container empacota, em uma única unidade: o código + as dependências + bibliotecas + as configurações do ambiente. Esse pacote roda de forma idêntica em qualquer máquina garantindo a reprodutibilidade dos dados.

