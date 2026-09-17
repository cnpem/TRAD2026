# Questionário de Construção de Containers e Reprodutibilidade

Dataset analisado:

1. Qual a diferença entre um container e uma máquina virtual? E de container para ambiente conda?

Resposta: Container empacota o código e o que mais será usado, rodando com reprodutibilidade em qualquer máquina. Máquina virtual cria um sistema operacional inteiro, sendo mais pesado. O Conda organiza principalmente os programas e bibliotecas necessários para uma análise.

2. Por que usamos Singularity/Apptainer em cluster e não Docker?

Resposta: Pois permite executar sem privilégio de root, toda imagem vira um único arquivo, integra bem com o cluster.

3. Para que serve cada uma das seções %post, %environment e %runscript em uma definition file?

Resposta: %post — comandos durante o build: instalar softwares e dependências. %environment — variáveis de ambiente definidas em tempo de execução. %runscript — o que roda ao chamar singularity run.

4. O que é um bind mount e por que ele é necessário?

Resposta: Serve para montar pastas do host dentro do container para acessar dados.

5. Como o uso de containers contribui para a reprodutibilidade de uma análise?

Resposta: Mantém versões específicas de programas, bibliotecas e dependências, permitindo reproduzir o mesmo ambiente de execução.
