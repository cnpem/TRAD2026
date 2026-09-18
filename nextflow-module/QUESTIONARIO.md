# Questionário do Módulo III - Nextflow | Explorando pipelines do nf-core

Dataset analisado:

Grupo:

1. O mesmo pipeline nf-core/ampliseq pode ser executado em diferentes HPC ou na nuvem. O que deve permanecer igual para que a análise continue reproduzível e o que necessariamente muda entre esses ambientes?

R: As versões dos softwares utilizados, e os bancos de dados de referência devem permanecer igual. Os diretórios dos componentes e comandos organizadores de fila.



2. Durante uma execução com -resume, alteramos apenas um parâmetro relacionado à etapa taxonômica. O Nextflow deveria repetir todo o pipeline? Explique por que algumas tasks podem ser reutilizadas e outras precisam ser executadas novamente.

R: Depende. Caso as etapas anteriores ou ou atual envolvam a aplicação desse parâmetro, vai ser executado novamente, caso contrário não há necessidade de reexecução.



3. No Waterwaste, observamos diferenças de abundância relativa entre surface\_water, hospital\_wastewater e urban\_wastewater. Antes de concluir que o tipo de amostra explica essas diferenças, que aspectos do desenho experimental e dos metadados deveriam ser examinados?

R:

4. Uma execução do pipeline terminou com sucesso. Quais informações, arquivos ou registros deveriam ser preservados para que outro pesquisador consiga reproduzir essa mesma análise no futuro?

R:

5. Dois pesquisadores executam o mesmo nf-core/ampliseq sobre os mesmos dados, mas obtêm resultados diferentes. Quais elementos da execução você investigaria primeiro para identificar a origem da diferença?

R: Verificar os parametros

