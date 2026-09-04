# Questionário de controle de qualidade

Dataset analisado:

1. Quais arquivos deste exercício devem ser versionados pelo Git e quais não devem? Considere FASTQ, relatórios de qualidade, scripts, arquivos de configuração, metadados e resultados intermediários. Justifique.

R:Os scripts, para permitir que outras pessoas visualicem e editem os scripts. Os dados não devem ser compartilhados no repositório.

2. Você recebe apenas os arquivos de resultados de uma análise e o endereço do repositório Git correspondente. Quais informações adicionais seriam necessárias para reproduzir completamente a análise? Considere dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código.

R: Para reproduzir completamente o experimento, seriam necessários os dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código. Agora, caso eu queira reproduzir os tipos análises do repositório utilizando meus dados, seriam necessários somente as versões de software, o ambiente computacional e versão do código

3. Um colega afirma que sua análise é reprodutível porque todos os scripts estão disponíveis no GitHub. Essa afirmação é suficiente? Avalie criticamente e indique pelo menos três elementos adicionais necessários para que outra pessoa possa reproduzir o processamento do dataset.

R:

4. Considere que uma queda de qualidade foi identificada nas regiões finais das leituras. Você modifica os parâmetros de *trimming* e executa novamente a análise. Descreva como essa mudança deveria ser registrada no Git para que seja possível comparar o resultado anterior com o novo resultado e posteriormente recuperar qualquer uma das duas versões da análise.

R: Eu modificaria os parametros utilizados pela ferramenta e, no comitt, colocaria um titulo descritivo sobre o que foi modificado no commit. 

5. Após o novo processamento, algumas métricas de qualidade melhoraram, mas o número total de leituras diminuiu. Como você decidiria se a modificação foi realmente benéfica? Quais métricas compararia e como documentaria essa decisão no repositório?

R: Depende dos parametros, pois se a porcentagem de perda de reads for muito alta em relacao ao aumento da qualidade, perderia muita informacao sobre a amostra. 
