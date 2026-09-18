# Questionário do Módulo III - Nextflow | Explorando pipelines do nf-core

Dataset analisado:

Grupo: 6

1. O mesmo pipeline nf-core/ampliseq pode ser executado em diferentes HPC ou na nuvem. O que deve permanecer igual para que a análise continue reproduzível e o que necessariamente muda entre esses ambientes?

R: Os dados e as versões dos programas devem parmanecer iguais, bem como o ambiente NF core. Muda as configurações da run e os devidos orquestradores.

2. Durante uma execução com -resume, alteramos apenas um parâmetro relacionado à etapa taxonômica. O Nextflow deveria repetir todo o pipeline? Explique por que algumas tasks podem ser reutilizadas e outras precisam ser executadas novamente.

R: Não, ele utiliza resultados de ferramentas rodadas anteriormente que já finalizaram. Tasks que precisam ser rodadas novamente são as diretamente associadas a etapa taxonômica.

3. No Waterwaste, observamos diferenças de abundância relativa entre surface_water, hospital_wastewater e urban_wastewater. Antes de concluir que o tipo de amostra explica essas diferenças, que aspectos do desenho experimental e dos metadados deveriam ser examinados?

R: Verificar se todas possuem a mesma profundidade de sequenciamento e se foram executados os mesmo padrões de trimming/limpeza.

4. Uma execução do pipeline terminou com sucesso. Quais informações, arquivos ou registros deveriam ser preservados para que outro pesquisador consiga reproduzir essa mesma análise no futuro?

R: Devem ser preservados os diretórios summary_report e pipeline_info.

5. Dois pesquisadores executam o mesmo nf-core/ampliseq sobre os mesmos dados, mas obtêm resultados diferentes. Quais elementos da execução você investigaria primeiro para identificar a origem da diferença?

R: Começaria investigando se os ambientes nf-core/ampliseq tem a mesma versão, se ambos utilizaram a versão default ou houve alguma alteração.

