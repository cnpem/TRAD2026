# Questionário do Módulo III - Nextflow | Explorando pipelines do nf-core

Dataset analisado:

Grupo:

1. O mesmo pipeline nf-core/ampliseq pode ser executado em diferentes HPC ou na nuvem. O que deve permanecer igual para que a análise continue reproduzível e o que necessariamente muda entre esses ambientes?

R: Os caminhos para os diretórios (input, output) devem ser modificados. Os parâmetros das análises devem permanecer.

2. Durante uma execução com -resume, alteramos apenas um parâmetro relacionado à etapa taxonômica. O Nextflow deveria repetir todo o pipeline? Explique por que algumas tasks podem ser reutilizadas e outras precisam ser executadas novamente.

R: Os caminhos para os diretórios (input, output) devem ser modificados. Os parâmetros das análises devem permanecer.

3. No Waterwaste, observamos diferenças de abundância relativa entre surface_water, hospital_wastewater e urban_wastewater. Antes de concluir que o tipo de amostra explica essas diferenças, que aspectos do desenho experimental e dos metadados deveriam ser examinados?

R: Examinar se todas amostras foram examinadas com os mesmos reagentes, realizando as análises das amostras de maneira concomitante.

4. Uma execução do pipeline terminou com sucesso. Quais informações, arquivos ou registros deveriam ser preservados para que outro pesquisador consiga reproduzir essa mesma análise no futuro?

R: Examinar se todas amostras foram examinadas com os mesmos reagentes, realizando as análises das amostras de maneira concomitante.

5. Dois pesquisadores executam o mesmo nf-core/ampliseq sobre os mesmos dados, mas obtêm resultados diferentes. Quais elementos da execução você investigaria primeiro para identificar a origem da diferença?

R:Consultaria o banco de dados de referencia para os resultados.
