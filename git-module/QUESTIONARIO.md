# Questionário de controle de qualidade

Dataset analisado:

1. Quais arquivos deste exercício devem ser versionados pelo Git e quais não devem? Considere FASTQ, relatórios de qualidade, scripts, arquivos de configuração, metadados e resultados intermediários. Justifique.

R: Scripts, arquivos de configuração, metadados não sensíveis e relatórios de qualidade devem ser versionados, pois documentam e permitem reproduzir a análise. Já os arquivos FASTQ e os resultados intermediários não devem ser versionados, porque geralmente são grandes e podem ser obtidos ou gerados novamente. 



2. Você recebe apenas os arquivos de resultados de uma análise e o endereço do repositório Git correspondente. Quais informações adicionais seriam necessárias para reproduzir completamente a análise? Considere dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código.

R:

3. Um colega afirma que sua análise é reprodutível porque todos os scripts estão disponíveis no GitHub. Essa afirmação é suficiente? Avalie criticamente e indique pelo menos três elementos adicionais necessários para que outra pessoa possa reproduzir o processamento do dataset.

R: Não, existem outras questões que comprometem a reprodutibilidade como por exemplo o controle de versões dos pacotes utilizados, ou documentação das instruções de uso ou preparação dos dados para que a analise seja executada como o esperado.

4. Considere que uma queda de qualidade foi identificada nas regiões finais das leituras. Você modifica os parâmetros de *trimming* e executa novamente a análise. Descreva como essa mudança deveria ser registrada no Git para que seja possível comparar o resultado anterior com o novo resultado e posteriormente recuperar qualquer uma das duas versões da análise.

R: Registrar a alteração como um novo commit, sem sobrescrever a anterior, descrevendo o motivo da mudança.

5. Após o novo processamento, algumas métricas de qualidade melhoraram, mas o número total de leituras diminuiu. Como você decidiria se a modificação foi realmente benéfica? Quais métricas compararia e como documentaria essa decisão no repositório?

R: 

