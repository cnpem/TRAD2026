# Questionário do Módulo III - Nextflow | Explorando pipelines do nf-core

Dataset analisado: Waterwaste

Grupo: 1

1. O mesmo pipeline nf-core/ampliseq pode ser executado em diferentes HPC ou na nuvem. O que deve permanecer igual para que a análise continue reproduzível e o que necessariamente muda entre esses ambientes?

R: O que deve permanecer igual é a versão do pipeline e as entradas do pipeline (folha de amostras, os metadados e os arquivos de parâmetros). O que vai mudar entre os ambientes são os usuários que estão executando o pipeline, ou o perfil de configuração das diferentes estruturas.

2. Durante uma execução com -resume, alteramos apenas um parâmetro relacionado à etapa taxonômica. O Nextflow deveria repetir todo o pipeline? Explique por que algumas tasks podem ser reutilizadas e outras precisam ser executadas novamente.

R: Não há necessidade de repetir o pipeline inteiro, pois a análise taxonômica ocorre no meio do pipeline. Algumas tasks podem ser reutilizadas pois o pipeline salva cada etapa assim que ela é executada (no caso do ampliseq: Pre-processing, Infer ASVs, Post-processing vem antes de Taxonomic Classification). Se as modificações são em etapas finais, as etapas iniciais não precisam ser repetidas. Caso as modificações sejam nas etapas iniciais (mudar parâmetros na etapa de análise de qualidade e montagem de contigs), as etapas posteriores (que dependem de etapas iniciais) devem ser executadas novamente.

3. No Waterwaste, observamos diferenças de abundância relativa entre surface\_water, hospital\_wastewater e urban\_wastewater. Antes de concluir que o tipo de amostra explica essas diferenças, que aspectos do desenho experimental e dos metadados deveriam ser examinados?

R: Se o desenho experimental tem esforço amostral similar entre os tipos de amostras e que permitem validar sua comparação. Também deve ser checado se a qualidade das leituras é aceitável em todos os dados de diferentes amostras e se quantidades suficientes de leituras foram utilizadas (qualidade e profundidade).

4. Uma execução do pipeline terminou com sucesso. Quais informações, arquivos ou registros deveriam ser preservados para que outro pesquisador consiga reproduzir essa mesma análise no futuro?

R: Deve-se preservar a versão do workflow, os arquivos de entrada, o script do processo, os parâmetros e containers utilizados, além do arquivo de metadados utilizado.

5. Dois pesquisadores executam o mesmo nf-core/ampliseq sobre os mesmos dados, mas obtêm resultados diferentes. Quais elementos da execução você investigaria primeiro para identificar a origem da diferença?

R: investigaria se as versões são realmente as mesmas, se os scripts do processo são os mesmos e se as entradas do pipeline estão corretas (exemplo: identificadores de samplesheet.csv e metadata.tsv são os mesmos), por fim investigaria os metadados, pois viabiliza a comparação da análise.
