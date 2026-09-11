# Questionário de Construção de Containers e Reprodutibilidade

Dataset analisado:

1. Qual a diferença entre um container e uma máquina virtual? E de container para ambiente conda?

Resposta: A maquina virtual é um emulador local de um ambiente e sua infra-estrutura (hardware), enquanto o container é a instalação de um sistema operacional e diversos softwares em um ambiente isolado e controlado. O ambiente conda isola apenas ao nivel de pacotes e suas dependências.

2. Por que usamos Singularity/Apptainer em cluster e não Docker?

Resposta: Por causa da necessidades de permissão como root do Docker, apresentando riscos de segurança em um ambiente computacional compartilhado..

3. Para que serve cada uma das seções %post, %environment e %runscript em uma definition file?

Resposta: %post realiza comandos no sistema operacional, executado durante a construção do container; %environemnt define variáveis no ambiente; %runcript serve para rodar rotinas específicas na execução do container.

4. O que é um bind mount e por que ele é necessário?

Resposta: Ele é necessário para indicar para o sistema dentro do container, qual é seu contexto dentro da máquina em que ele está.

5. Como o uso de containers contribui para a reprodutibilidade de uma análise?

Resposta: Controlando dependências em um sistema isolado, permitindo reproduzir resultados de programas computacionais. O container também ajuda na descrição do processo necessário para criar esse ambiente controlado e isolado.
