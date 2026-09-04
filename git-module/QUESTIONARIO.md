# Questionário de controle de qualidade

Dataset analisado: RNA-Seq Acai

1. Quais arquivos deste exercício devem ser versionados pelo Git e quais não devem? Considere FASTQ, relatórios de qualidade, scripts, arquivos de configuração, metadados e resultados intermediários. Justifique.

R: Os arquivos que devem ser versionados são FASTQ, scripts, e arquivos de configuração pois eles ajudam na reprodução do resultado, os relatórios de qualidade também, já que dependendo da análise o tempo de processamento é longo. No entanto, metadados e resultados intermediários não devem ser versionados.



2. Você recebe apenas os arquivos de resultados de uma análise e o endereço do repositório Git correspondente. Quais informações adicionais seriam necessárias para reproduzir completamente a análise? Considere dados de entrada, versões de software, parâmetros, ambiente computacional e versão do código.

R: Quais dados foram utilizados como entrada; a versão do software, e os parâmetros utilizados para o trimming.  

3. Um colega afirma que sua análise é reprodutível porque todos os scripts estão disponíveis no GitHub. Essa afirmação é suficiente? Avalie criticamente e indique pelo menos três elementos adicionais necessários para que outra pessoa possa reproduzir o processamento do dataset.

R:Baseando inteiramente na interpretacao do Copilot

Não. Disponibilizar os scripts no GitHub é necessário, mas não suficiente para garantir reprodutibilidade. No caso do pipeline mostrado no TRAD2026 - Euterpe\_oleracea\_ MultiQC Report, também seriam necessários pelo menos: (i) os dados de entrada ou acesso a eles (amostras SRR33581420–SRR33581424), (ii) versões exatas dos softwares e parâmetros utilizados (MultiQC, NanoStat, NanoPlot etc.) e (iii) um registro detalhado do ambiente computacional e da ordem de execução do workflow.



4. Considere que uma queda de qualidade foi identificada nas regiões finais das leituras. Você modifica os parâmetros de *trimming* e executa novamente a análise. Descreva como essa mudança deveria ser registrada no Git para que seja possível comparar o resultado anterior com o novo resultado e posteriormente recuperar qualquer uma das duas versões da análise.

R:Essa mudança deveria ser registrada a partir de um commit no GIT apresentando a mudança realizada para gerar os resultados obtidos. 



5. Após o novo processamento, algumas métricas de qualidade melhoraram, mas o número total de leituras diminuiu. Como você decidiria se a modificação foi realmente benéfica? Quais métricas compararia e como documentaria essa decisão no repositório?

R: Após esse novo processamento hipotético, as modificações nos dados poderão ser avaliadas comparando os resultados da análise do controle de qualidade pré e pós processamento. Nesse sentido, seria observado principalmente o gráfico de Reads By Quality gerado pelo software NanoStat, onde deve haver um aumento da porcentagem de reads com qualidade maior que 25. Essa decisão seria documentada no repositório usando um arquivo .md ou .txt contendo os parâmetros usados para o processamento, e também os critérios que levaram o usuário a tomar as decisões para o processamento dos dados.

