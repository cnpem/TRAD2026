# Questionário de controle de qualidade

Dataset analisado: Ipomoea cavalcantei

1. Quais arquivos deste exercício devem ser versionados pelo Git e quais não devem? Considere FASTQ, relatórios de qualidade, scripts, arquivos de configuração, metadados e resultados intermediários. Justifique.

R: Em geral, arquivos grandes não devem ser versionados pelo Git. No caso das análises aqui realizadas, o FASTQ apresenta \~45GB, não sendo adequado para adicionar no repositório do Git. Para garantir a reprodutibilidade, scripts e arquivos de configuração são mais importantes para manter a boa consistência dos resultados gerais. Resultados intermediários não necessitam versionamento. Relatório de qualidade pode ser utilizado para servir como guia para confirmar/avaliar a consistência dos resultados caso uma outra pessoa decida reproduzir as análises.  

2. Você recebe apenas os arquivos de resultados de uma análise e o endereço do repositório Git correspondente. Quais informações adicionais seriam necessárias para reproduzir completamente a análise? Considere dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código.

R: 

3. Um colega afirma que sua análise é reprodutível porque todos os scripts estão disponíveis no GitHub. Essa afirmação é suficiente? Avalie criticamente e indique pelo menos três elementos adicionais necessários para que outra pessoa possa reproduzir o processamento do dataset.

R: 

4. Considere que uma queda de qualidade foi identificada nas regiões finais das leituras. Você modifica os parâmetros de *trimming* e executa novamente a análise. Descreva como essa mudança deveria ser registrada no Git para que seja possível comparar o resultado anterior com o novo resultado e posteriormente recuperar qualquer uma das duas versões da análise.

R: 

5. Após o novo processamento, algumas métricas de qualidade melhoraram, mas o número total de leituras diminuiu. Como você decidiria se a modificação foi realmente benéfica? Quais métricas compararia e como documentaria essa decisão no repositório?

R:

