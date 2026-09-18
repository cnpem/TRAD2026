# Questionário do Módulo III - Nextflow | Explorando pipelines do nf-core

Dataset analisado:

Grupo:

1. O mesmo pipeline nf-core/ampliseq pode ser executado em diferentes HPC ou na nuvem. O que deve permanecer igual para que a análise continue reproduzível e o que necessariamente muda entre esses ambientes?

R: Devem permanecer iguais os dados de entrada, versão do pipeline, parâmetros, metadados, bancos de dados e versões das ferramentas. O que muda são aspectos da infraestrutura, como HPC/nuvem, recursos computacionais, sistema de filas e caminhos dos arquivos.

2. Durante uma execução com -resume, alteramos apenas um parâmetro relacionado à etapa taxonômica. O Nextflow deveria repetir todo o pipeline? Explique por que algumas tasks podem ser reutilizadas e outras precisam ser executadas novamente.

R:Não. Com -resume, o Nextflow reutiliza as tasks que não foram afetadas pela alteração. Como apenas a etapa taxonômica mudou, etapas anteriores podem ser aproveitadas, enquanto a taxonomia e as etapas dependentes dela são executadas novamente.

3. No Waterwaste, observamos diferenças de abundância relativa entre surface\_water, hospital\_wastewater e urban\_wastewater. Antes de concluir que o tipo de amostra explica essas diferenças, que aspectos do desenho experimental e dos metadados deveriam ser examinados?

R:Devem ser avaliados número de amostras, local e período de coleta, método de processamento, lotes de extração/sequenciamento e profundidade de sequenciamento. Esses fatores podem atuar como confundidores e explicar as diferenças observadas.

4. Uma execução do pipeline terminou com sucesso. Quais informações, arquivos ou registros deveriam ser preservados para que outro pesquisador consiga reproduzir essa mesma análise no futuro?

R:Devem ser preservados versão do pipeline e do Nextflow, parâmetros/comando, dados e metadados de entrada, bancos de dados e versões das ferramentas, containers e logs/relatórios da execução.

5. Dois pesquisadores executam o mesmo nf-core/ampliseq sobre os mesmos dados, mas obtêm resultados diferentes. Quais elementos da execução você investigaria primeiro para identificar a origem da diferença?

R:Primeiro compararia versão do pipeline, parâmetros, arquivos de entrada, metadata, bancos de dados, versões das ferramentas/containers e logs. Depois, compararia os resultados intermediários para identificar em qual etapa as execuções começaram a divergir.

