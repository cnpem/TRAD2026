# Questionário de controle de qualidade

Dataset analisado: Ipomoea cavalcantei

1. Quais arquivos deste exercício devem ser versionados pelo Git e quais não devem? Considere FASTQ, relatórios de qualidade, scripts, arquivos de configuração, metadados e resultados intermediários. Justifique.

R:

2. Você recebe apenas os arquivos de resultados de uma análise e o endereço do repositório Git correspondente. Quais informações adicionais seriam necessárias para reproduzir completamente a análise? Considere dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código.

R: Para reproduzir completamente a análise, seria necessário ter acesso aos dados de entrada utilizados, aos scripts e à versão exata do código correspondente aos resultados apresentados, além das versões das linguagens, bibliotecas e demais dependências de software utilizadas. Também seriam necessários os parâmetros e configurações da análise, o ambiente computacional em que ela foi executada e instruções claras sobre a ordem de execução dos arquivos e o fluxo de processamento. No repositório do GitHub, poderia ser feito um fork e um clone local para acessar e executar esses arquivos, mas é importante verificar qual versão do código foi utilizada originalmente, pois atualizações nos scripts, pacotes e dependências podem alterar os resultados.



3. Um colega afirma que sua análise é reprodutível porque todos os scripts estão disponíveis no GitHub. Essa afirmação é suficiente? Avalie criticamente e indique pelo menos três elementos adicionais necessários para que outra pessoa possa reproduzir o processamento do dataset.

R: Não. A disponibilização dos scripts no GitHub, por si só, não é suficiente para garantir que uma análise seja reprodutível, pois é necessário que outra pessoa consiga reproduzir as mesmas condições utilizadas na análise original. Para isso, além dos códigos, devem estar disponíveis o dataset utilizado, incluindo as etapas de pré-processamento e transformação dos dados; as dependências e o ambiente computacional, como versões da linguagem, bibliotecas e pacotes; e os métodos, parâmetros e configurações empregados. Também é importante fornecer instruções claras sobre como executar os scripts e reproduzir o fluxo completo de processamento. Dessa forma, a reprodutibilidade computacional depende da possibilidade de reconstruir as mesmas condições de dados, métodos, parâmetros e ambiente utilizadas na análise original, permitindo obter resultados equivalentes aos originais.



4. Considere que uma queda de qualidade foi identificada nas regiões finais das leituras. Você modifica os parâmetros de *trimming* e executa novamente a análise. Descreva como essa mudança deveria ser registrada no Git para que seja possível comparar o resultado anterior com o novo resultado e posteriormente recuperar qualquer uma das duas versões da análise.

R:

5. Após o novo processamento, algumas métricas de qualidade melhoraram, mas o número total de leituras diminuiu. Como você decidiria se a modificação foi realmente benéfica? Quais métricas compararia e como documentaria essa decisão no repositório?

R:

