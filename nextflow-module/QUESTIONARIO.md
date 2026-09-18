# Questionário do Módulo III - Nextflow | Explorando pipelines do nf-core

Dataset analisado: Waterwaste 16S

Grupo: 2

1. O mesmo pipeline nf-core/ampliseq pode ser executado em diferentes HPC ou na nuvem. O que deve permanecer igual para que a análise continue reproduzível e o que necessariamente muda entre esses ambientes?

R: Os parâmetros usados para rodar a pipeline devem ser iguais entre os ambientes. Também é importante garantir o uso de container dentro da pipeline para garantir um ambiente controlado de execução. O mais importante é garantir que as versões do Nextflow, da pipeline sendo usada e de cada programa que será rodado seja o mesmo. Além disso, é importante garantir que os arquivos de samples e configurações usados sejam o mesmo.

2. Durante uma execução com -resume, alteramos apenas um parâmetro relacionado à etapa taxonômica. O Nextflow deveria repetir todo o pipeline? Explique por que algumas tasks podem ser reutilizadas e outras precisam ser executadas novamente.

R: Se a etapa taxonômica ainda não foi executada, não seria necessário rodar de novo. Agora se a etapa já rodou, seria necessário rodar a pipeline do zero pois a mudança de parâmetros com certeza alterará os resultados gerados.

3. No Waterwaste, observamos diferenças de abundância relativa entre surface_water, hospital_wastewater e urban_wastewater. Antes de concluir que o tipo de amostra explica essas diferenças, que aspectos do desenho experimental e dos metadados deveriam ser examinados?

R: Antes de atribuir as diferenças ao tipo de amostra, é necessário verificar o número e o balanceamento das réplicas, além de possíveis fatores de confusão, como local e data de coleta, método de extração, lote de processamento, plataforma e profundidade de sequenciamento. Também é importante avaliar se esses fatores estão associados sistematicamente a cada tipo de amostra.

4. Uma execução do pipeline terminou com sucesso. Quais informações, arquivos ou registros deveriam ser preservados para que outro pesquisador consiga reproduzir essa mesma análise no futuro?

R: versão da pipeline, versão do nextflow, dados usados, arquivos de parâmetros, config e samples usados. Todos esses dados saem no report gerado pela própria pipe-line no fim da corrida, o que facilita esse controle.

5. Dois pesquisadores executam o mesmo nf-core/ampliseq sobre os mesmos dados, mas obtêm resultados diferentes. Quais elementos da execução você investigaria primeiro para identificar a origem da diferença?

R: Primeiro, a versão usada do Nextflow é a mesma? Se sim, a versão da pipeline é a mesma? Se sim, os parâmetros de execução usados foram o mesmo? Todos os aspectos de execução que forem diferentes podem ser a causa do resultado ser diferente.
