# Questionário de controle de qualidade

Dataset analisado: Ipomoea_cavalcantei

1. Quais arquivos deste exercício devem ser versionados pelo Git e quais não devem? Considere FASTQ, relatórios de qualidade, scripts, arquivos de configuração, metadados e resultados intermediários. Justifique.

R:

2. Você recebe apenas os arquivos de resultados de uma análise e o endereço do repositório Git correspondente. Quais informações adicionais seriam necessárias para reproduzir completamente a análise? Considere dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código.

R: 

3. Um colega afirma que sua análise é reprodutível porque todos os scripts estão disponíveis no GitHub. Essa afirmação é suficiente? Avalie criticamente e indique pelo menos três elementos adicionais necessários para que outra pessoa possa reproduzir o processamento do dataset.

R:

4. Considere que uma queda de qualidade foi identificada nas regiões finais das leituras. Você modifica os parâmetros de *trimming* e executa novamente a análise. Descreva como essa mudança deveria ser registrada no Git para que seja possível comparar o resultado anterior com o novo resultado e posteriormente recuperar qualquer uma das duas versões da análise.

R: Primeiro deverá ser criada uma nova branch com os scripts que alteram os valores de trimming incluídos, com um nome, por exemplo, "trimmingvalues-changed". Nessa nova branch os scripts podem ser modificados, alterando os valores de trimming para o valor desejado. A análise de qualidade pode ser então realizada com os arquivos de sequenciamento, sem modificar os códigos originais. Os novos resultados devem ser salvos em um novo diretório results_trimming_newvalue. Os dois resultados então podem ser comparados. Caso deseje recuperar a versão antiga, é necessário alterar o branch e seguir com o branch main. Caso deseje usar a nova modificação e incluí-la no branch main, deve ser realizado o merge do branch trimmingvalues-changed no branch main e opcionalmente pode ser excluído o branch trimmingvalues-changed.

5. Após o novo processamento, algumas métricas de qualidade melhoraram, mas o número total de leituras diminuiu. Como você decidiria se a modificação foi realmente benéfica? Quais métricas compararia e como documentaria essa decisão no repositório?

R: As métricas para comparação podem ser as métricas de Read N50, Median Qual, # Reads (K) e Total Bases (Mb). O Reads N50 deve ser o maior possível, caso a Median Qual aumente e o Reads N50 continue parecido ou igual, então pode ser considerado que a modificação foi benéfica. Também os valores de Reads (K) e Total Bases (MB) devem continuar elevados, sem ter muita perda de informação, pois como ocorreu que o número total de leituras diminuiu, essa queda não pode ser tão expressiva a ponto de perder consideravelmente o volume de dados. Para documentação da decisão no repositório, criaria um pull request incluindo um título e a descrição explicando os motivos da solicitação do pull, e incluiria outras pessoas reponsáveis pela análise do repositório para realizarem a conferência e atualizações dessas novas modificações no código.
