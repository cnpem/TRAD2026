# Questionário de controle de qualidade

Dataset analisado: Euterpe oleracea

1. Quais arquivos deste exercício devem ser versionados pelo Git e quais não devem? Considere FASTQ, relatórios de qualidade, scripts, arquivos de configuração, metadados e resultados intermediários. Justifique.

R: Scripts, arquivos de configuração e metadados devem ser versionados pois alterações neles podem alterar os resultados finais obtidos.

2. Você recebe apenas os arquivos de resultados de uma análise e o endereço do repositório Git correspondente. Quais informações adicionais seriam necessárias para reproduzir completamente a análise? Considere dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código.

R: dados de entrada, versões de software, parâmetros, ambiente computacional, versão do código, hardware, licenças.

3. Um colega afirma que sua análise é reprodutível porque todos os scripts estão disponíveis no GitHub. Essa afirmação é suficiente? Avalie criticamente e indique pelo menos três elementos adicionais necessários para que outra pessoa possa reproduzir o processamento do dataset.

R:

4. Considere que uma queda de qualidade foi identificada nas regiões finais das leituras. Você modifica os parâmetros de *trimming* e executa novamente a análise. Descreva como essa mudança deveria ser registrada no Git para que seja possível comparar o resultado anterior com o novo resultado e posteriormente recuperar qualquer uma das duas versões da análise.

R: É necessário fazer commit das 2 versões e fazer um branch para modificações.

5. Após o novo processamento, algumas métricas de qualidade melhoraram, mas o número total de leituras diminuiu. Como você decidiria se a modificação foi realmente benéfica? Quais métricas compararia e como documentaria essa decisão no repositório?

R: A decisão seria feita em relação aos parâmetros de qualidade e no número total de leituras. A documentação dos resultados pode ser feita através de commits em que suas mensgaens informam os parâmetros utilizados.
