<h1 align="center"> Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026): Descrição dos conjuntos de dados ômicos </h1>

<p align="center">
Laboratório Nacional de Biociências (LNBio) · Laboratório Nacional de Biorrenováveis (LNBR) · Centro Nacional de Pesquisa em Energia e Materiais (CNPEM)
</p>

---

## Uma breve introdução às ciências ômicas

As **ciências ômicas** investigam sistemas biológicos por meio da análise, em larga escala, de moléculas e informações como DNA, RNA, proteínas e metabólitos. Essas abordagens permitem compreender não apenas o que está presente em uma amostra, mas também como os diferentes níveis da biologia se relacionam e variam entre organismos, ambientes e condições.

Como cada tipo de informação revela um aspecto diferente do sistema biológico, as ciências ômicas são organizadas em abordagens complementares:

* **genômica:** estuda o DNA de um organismo, incluindo seus genes, sua organização e suas variações;
* **transcriptômica:** analisa os RNAs produzidos e indica quais genes estão ativos em determinada condição;
* **proteômica:** investiga as proteínas produzidas, suas funções e suas variações;
* **metabolômica:** analisa os metabólitos e ajuda a compreender as transformações químicas que ocorrem nas células;
* **metagenômica:** estuda o material genético de comunidades microbianas, permitindo investigar quais organismos estão presentes e qual é o seu potencial funcional.

Essas camadas oferecem perspectivas diferentes, mas complementares. O genoma representa o repertório genético disponível, enquanto o transcriptoma mostra quais partes desse repertório estão sendo utilizadas. Proteínas e metabólitos ajudam a compreender as atividades celulares, e a metagenômica amplia essa perspectiva para comunidades inteiras, conectando diversidade microbiana, funções biológicas e ambiente.

Em conjunto, essas informações permitem construir uma visão mais integrada dos sistemas biológicos e investigar perguntas como:

* Quem está presente?
* O que existe no genoma?
* Quais genes estão ativos?
* Que funções uma comunidade microbiana pode desempenhar?
* Como organismos e comunidades respondem a diferentes ambientes ou condições?

Cada ciência ômica utiliza estratégias experimentais e computacionais próprias. No TRAD2026, o foco estará nas abordagens baseadas no **sequenciamento de DNA e RNA**. Nessas técnicas, o material biológico é transformado em milhões de sequências, chamadas **leituras** ou *reads*, que serão o ponto de partida das análises realizadas ao longo do curso.

## Abordagens de sequenciamento trabalhadas no TRAD2026

### Genômica e sequenciamento do genoma completo

O sequenciamento do genoma completo, conhecido como **WGS** (*Whole Genome Sequencing*), examina o DNA de um organismo ao longo de todo o genoma. A partir desses dados, é possível investigar genes, variações genéticas, organização do genoma e relações evolutivas.

No TRAD2026, serão utilizados dados genômicos de dorado, bugio e cana-de-açúcar.

### Metagenômica *shotgun*

A metagenômica *shotgun* estuda o DNA total obtido diretamente de uma amostra que contém uma comunidade de organismos. Essa amostra pode vir do intestino de um animal, da água, do solo ou de outros ambientes.

Como não há seleção prévia de um gene específico, os dados podem representar diferentes microrganismos e também DNA do hospedeiro. A análise permite investigar:

- diversidade e composição da comunidade microbiana;
- genes e vias metabólicas presentes;
- potencial funcional da comunidade;
- padrões ecológicos e possíveis associações entre microrganismos;
- genomas microbianos reconstruídos a partir do metagenoma.

No TRAD2026, serão utilizados dois conjuntos de metagenômica *shotgun*: microbiota da capivara e microbiota de abelhas.

### Sequenciamento de amplicons do gene 16S rRNA

O sequenciamento de amplicons é uma abordagem direcionada. Uma região específica do DNA é amplificada por **PCR** e, em seguida, sequenciada. O fragmento produzido nessa etapa é chamado de **amplicon**.

Para estudar bactérias e arqueias, um dos marcadores mais utilizados é o gene 16S rRNA. Suas regiões conservadas permitem a amplificação, enquanto as regiões variáveis ajudam na identificação taxonômica.

O método apresenta menor custo, gera menos dados e facilita a comparação da composição microbiana entre amostras. Por outro lado, analisa somente a região selecionada, pode não distinguir espécies próximas e não descreve diretamente todo o potencial funcional da comunidade. A escolha dos primers e a etapa de PCR também podem introduzir vieses.

Enquanto o 16S ajuda a responder **quais bactérias e arqueias estão presentes**, a metagenômica *shotgun* oferece informações mais amplas sobre os genes e as funções da comunidade.

No TRAD2026, serão utilizados dois conjuntos de amplicon 16S: microbiota da capivara e amostras ambientais de água.

### RNA-seq e transcriptômica

O **transcriptoma** corresponde ao conjunto de RNAs produzidos por uma célula, tecido ou organismo em determinado momento. Como a produção de RNA muda durante o desenvolvimento e em resposta ao ambiente, a tratamentos ou a doenças, o transcriptoma funciona como um retrato da atividade gênica.

No RNA-seq, o RNA é extraído e geralmente convertido em DNA complementar, chamado **cDNA**, antes do sequenciamento. Após a análise computacional, as leituras são associadas a genes ou transcritos para estimar seus níveis de expressão.

O RNA-seq permite comparar a expressão gênica entre condições, estudar respostas a estímulos, acompanhar processos fisiológicos e identificar alterações associadas a doenças.

No TRAD2026, serão utilizados dois conjuntos de RNA-seq: transcriptoma de açaí e dados humanos de câncer de cabeça e pescoço.

## Do material biológico aos arquivos FASTQ

Cada abordagem prepara um tipo de material para o sequenciamento:

| Abordagem | O que é sequenciado |
| --- | --- |
| Genômica/WGS | Fragmentos do DNA genômico do organismo |
| Metagenômica *shotgun* | Fragmentos do DNA total da amostra |
| Amplicon 16S | Cópias da região selecionada do gene 16S rRNA |
| RNA-seq | cDNA produzido a partir do RNA da amostra |

Esse material é preparado como uma **biblioteca de sequenciamento**, uma coleção de fragmentos de DNA adaptados para serem reconhecidos e lidos pelo equipamento.

Em plataformas como a **Illumina**, milhões de fragmentos são sequenciados ao mesmo tempo. O equipamento identifica a ordem dos nucleotídeos e gera as leituras.

Quando o sequenciamento é **paired-end**, cada fragmento é lido pelas duas extremidades. Por isso, uma amostra costuma ser representada por dois arquivos:

- `amostra_R1.fastq.gz` ou `amostra_1.fastq.gz`: primeira leitura;
- `amostra_R2.fastq.gz` ou `amostra_2.fastq.gz`: segunda leitura.

R1 e R2 formam pares e devem ser processados em conjunto.

Após o processamento inicial da plataforma, as leituras são organizadas no formato **FASTQ**. Cada registro contém:

- um identificador;
- uma sequência de nucleotídeos;
- uma estimativa de qualidade para cada base.

A extensão `.gz` indica que o arquivo está compactado. A maioria das ferramentas de bioinformática trabalha diretamente com arquivos `.fastq.gz`, sem necessidade de descompactação.


Os arquivos FASTQ são os **dados brutos** do experimento. Eles ainda não informam diretamente quais genes, organismos ou funções estão presentes.

## Conjuntos de dados do TRAD2026

Os conjuntos apresentados a seguir serão explorados em diferentes atividades do curso.

| Categoria | Conjunto de dados | Organismo ou contexto | Tipo de dado |
| --- | --- | --- | --- |
| Genômica | Dorado | *Salminus brasiliensis* | WGS |
| Genômica | Buguio | *Alouatta* spp. | WGS |
| Genômica | Cana-de-açúcar | *Saccharum* spp. (híbrido) | WGS |
| Transcriptômica | Açaí | *Euterpe oleracea* | RNA-seq |
| Transcriptômica | Câncer de cabeça e pescoço | HNSCC, amostras humanas | RNA-seq |
| Metagenômica | Microbiota de abelhas | Microbiota intestinal de *Apis mellifera* | Metagenômica *shotgun* |
| Metagenômica | Microbiota de capivara | Microbiota intestinal de *Hydrochoerus hydrochaeris* | Metagenômica *shotgun* |
| Amplicon | Microbiota da capivara | Microbiota intestinal de *Hydrochoerus hydrochaeris* | Amplicon 16S rRNA |
| Amplicon | Água e efluentes | Amostras brasileiras coletadas em São Paulo | Amplicon 16S rRNA |

Ao todo, o TRAD2026 reúne **nove conjuntos de dados**: três genomas, dois transcriptomas, dois metagenomas *shotgun* e dois conjuntos de amplicon 16S.


### Origem dos dados

Os códigos `PRJNA` identificam BioProjects, enquanto os códigos `SRR` correspondem às corridas de sequenciamento depositadas no Sequence Read Archive (SRA). A tabela resume os dados selecionados para o curso.

| Conjunto | BioProject ou estudo | Acessos utilizados | Publicação associada |
| --- | --- | --- | --- |
| Dourado | `PRJNA792751`, `PRJNA1433447` e `PRJNA1433448` | `SRR17407720`, `SRR37670351`, `SRR37671906`, `SRR37715091`, `SRR37715180`, `SRR37718160` e `SRR37718161` | Graciano et al. (2022), para `SRR17407720`; projetos de 2026 ainda sem artigo associado |
| Bugios | `PRJNA1404690` | `SRR38321360–SRR38321371` | BioProject de 2026 ainda sem artigo associado |
| Cana-de-açúcar | `PRJNA272769` e `PRJNA244522` | `SRR1763296`, `SRR1774133–SRR1774141` e `SRR1974519` | Souza et al. (2019) |
| Açaí | `PRJNA1265274`, `PRJNA1265420` e `PRJNA1262982` | `SRR33642826–SRR33642829`, `SRR33642075–SRR33642078` e `SRR33581420–SRR33581425` | Barbosa et al. (2026) |
| HNSCC | `PRJNA727315`; `GSE173855` | `SRR14428032–SRR14428044` | Weber et al. (2022) |
| Microbiota de abelhas | `PRJNA977416` | `SRR24759596–SRR24759616` | Sbaghdi et al. (2024) |
| Metagenômica da capivara | `PRJNA563062` | `SRR11852046–SRR11852057` | Cabral et al. (2022) |
| 16S da capivara | `PRJNA563062` | `SRR11852069–SRR11852086` | Cabral et al. (2022) |
| 16S de água e efluentes | `PRJNA880881` | `SRR27211468–SRR27211473`, `SRR27211477`, `SRR27211486–SRR27211492`, `SRR27211499`, `SRR27211506–SRR27211512` e `SRR27211521–SRR27211522` | Scaccia et al. (2024) |

No conjunto de água e efluentes, serão utilizadas somente as amostras brasileiras: seis amostras de água da Raia da USP, seis de efluente hospitalar do Hospital das Clínicas da FMUSP e 12 de efluentes urbanos de duas estações de tratamento de São Paulo. As coletas ocorreram entre janeiro e junho de 2022. Os amplicons foram sequenciados em Ion Torrent S5 no modo **single-end**; portanto, essas amostras não possuem pares R1 e R2.

O conjunto de cana-de-açúcar inclui principalmente dados genômicos, mas o acesso `SRR1974519` corresponde a RNA-seq utilizado como informação complementar. Os dados de açaí e bugios também foram produzidos com tecnologias de leituras longas.

## Biodiversidade brasileira

Grande parte dos dados utilizados no TRAD2026 está associada à biodiversidade brasileira. O curso inclui espécies de interesse ecológico e agrícola, como o dorado, o bugio, a capivara, o açaí e a cana-de-açúcar. Há também conjuntos relacionados a microbiomas, ambientes aquáticos e saúde humana.

Entre os conjuntos selecionados, há dados públicos e resultados de pesquisas e colaborações científicas que envolveram equipes do Laboratório Nacional de Biorrenováveis (LNBR) e do Laboratório Nacional de Biociências (LNBio). Essa combinação aproxima o treinamento de situações reais de pesquisa desenvolvidas no CNPEM.

Esses dados permitem trabalhar com perguntas científicas reais e observar como as mesmas práticas de organização, controle de qualidade e reprodutibilidade podem ser aplicadas a diferentes áreas da biologia.

## Acesso aos dados

Os arquivos utilizados nas atividades estão disponíveis no **HPC Marvin**, no diretório compartilhado:

```text
/shared/training/TRAD2026/raw_data
```

### Organização das pastas

Cada pasta corresponde a um conjunto biológico e ao tipo de dado indicado abaixo:

| Pasta | Abordagem | Características dos dados |
| --- | --- | --- |
| `16S_Hydrochoerus_hydrochaeris/` | Amplicon 16S rRNA | Microbiota intestinal de capivara; Illumina paired-end |
| `16S_Waterwaste/` | Amplicon 16S rRNA | Água e efluentes do Brasil; Ion Torrent single-end |
| `Alouatta_sp/` | Genômica/WGS | Genomas de bugios; leituras longas PacBio e Oxford Nanopore |
| `Apis_mellifera/` | Metagenômica *shotgun* | Microbiota intestinal de abelhas; Illumina paired-end |
| `Euterpe_oleracea/` | RNA-seq | Transcriptoma de frutos de açaí; Oxford Nanopore single-end |
| `HNSCC/` | RNA-seq | Tumores humanos primários e recorrentes; Illumina paired-end |
| `MG_Hydrochoerus_hydrochaeris/` | Metagenômica *shotgun* | Microbiota intestinal de capivara; Illumina paired-end |
| `Saccharum_hybrid/` | Genômica/WGS | Cana-de-açúcar; inclui um acesso auxiliar de RNA-seq |
| `Salminus_brasiliensis/` | Genômica/WGS | Genoma do dourado; Illumina paired-end |

Nos conjuntos **paired-end**, cada amostra é representada por dois arquivos, geralmente identificados por `_1` e `_2` ou por `R1` e `R2`. Nos conjuntos **single-end**, há apenas um arquivo FASTQ por corrida de sequenciamento.

Nesse diretório, os dados estão organizados por conjunto:

```text
raw_data/
├── 16S_Hydrochoerus_hydrochaeris/
├── 16S_Waterwaste/
├── Alouatta_sp/
├── Apis_mellifera/
├── Euterpe_oleracea/
├── HNSCC/
├── MG_Hydrochoerus_hydrochaeris/
├── Saccharum_hybrid/
└── Salminus_brasiliensis/
```

### Primeiro acesso ao Marvin

Para ativar o usuário no Marvin, é necessário realizar o primeiro acesso por **SSH**, utilizando o terminal no Linux ou macOS, ou o PowerShell no Windows:

```bash
ssh <seu.login.cnpem>@marvin.cnpem.br
```

Substitua `<seu.login.cnpem>` pelo usuário do seu e-mail institucional, sem o domínio. Quando solicitado, informe a senha institucional. No primeiro acesso, também poderá ser necessário confirmar a identidade do servidor digitando `yes`.

O primeiro login permite acessar os arquivos, mas a autorização para submeter *jobs* ao **SLURM** e utilizar os **Interactive Apps** é concedida separadamente. Caso ainda não possua essa permissão, solicite-a pelo chamado [HPCC Marvin: Suporte ao usuário](https://cnpem.atlassian.net/servicedesk/customer/portal/181/group/536/create/2155).

O Marvin também pode ser acessado pelo navegador em [https://marvin.cnpem.br](https://marvin.cnpem.br). Esse endereço funciona na rede interna do CNPEM; fora do Centro, é necessário utilizar a VPN institucional.

As instruções completas estão disponíveis na documentação [Primeiros passos no HPCC Marvin](https://marvindocs.cnpem.br/02-primeiros-passos/index.html#primeiros-passos). Em caso de dúvida ou problema de acesso, consulte a equipe de suporte indicada nessa página.

Informações sobre a origem, os identificadores e as características dos conjuntos podem ser consultadas na planilha de dados do TRAD2026, a qual está disponível neste diretório com o nome #TRAD2026_Datasets.xlsx

---
## Referências e leituras complementares

1. BIÃO, L. F. Ciências Ômicas: Saindo do Zero. *Revista Blog Profissão Biotec*, v. 12, 2025. Disponível em: [https://profissaobiotec.com.br/ciencias-omicas-saindo-do-zero/](https://profissaobiotec.com.br/ciencias-omicas-saindo-do-zero/). Acesso em: 17 ago. 2026.

2. UNIVERSIDADE DE SÃO PAULO. O papel das ciências ômicas na compreensão dos distúrbios neurológicos. *Portal USP São Carlos*, 6 set. 2024. Disponível em: [https://saocarlos.usp.br/o-papel-das-ciencias-omicas-na-compreensao-dos-disturbios-neurologicos/](https://saocarlos.usp.br/o-papel-das-ciencias-omicas-na-compreensao-dos-disturbios-neurologicos/). Acesso em: 17 ago. 2026.

3. HU, T.; CHITNIS, N.; MONOS, D.; DINH, A. Next-generation sequencing technologies: an overview. *Human Immunology*, v. 82, n. 11, p. 801-811, 2021. [https://doi.org/10.1016/j.humimm.2021.02.012](https://doi.org/10.1016/j.humimm.2021.02.012).

4. LIU, Y.-X.; QIN, Y.; CHEN, T.; et al. A practical guide to amplicon and metagenomic analysis of microbiome data. *Protein & Cell*, v. 12, n. 5, p. 315-330, 2021. [https://doi.org/10.1007/s13238-020-00724-8](https://doi.org/10.1007/s13238-020-00724-8).

5. WEINROTH, M. D.; BELK, A. D.; DEAN, C.; et al. Considerations and best practices in animal science 16S ribosomal RNA gene sequencing microbiome studies. *Journal of Animal Science*, v. 100, n. 2, artigo skab346, 2022. [https://doi.org/10.1093/jas/skab346](https://doi.org/10.1093/jas/skab346).

6. KIM, N.; MA, J.; KIM, W.; et al. Genome-resolved metagenomics: a game changer for microbiome medicine. *Experimental & Molecular Medicine*, v. 56, p. 1501-1512, 2024. [https://doi.org/10.1038/s12276-024-01262-7](https://doi.org/10.1038/s12276-024-01262-7).

7. HONG, M.; TAO, S.; ZHANG, L.; et al. RNA sequencing: new technologies and applications in cancer research. *Journal of Hematology & Oncology*, v. 13, artigo 166, 2020. [https://doi.org/10.1186/s13045-020-01005-x](https://doi.org/10.1186/s13045-020-01005-x).

8. LI, X.; WANG, C.-Y. From bulk, single-cell to spatial RNA sequencing. *International Journal of Oral Science*, v. 13, artigo 36, 2021. [https://doi.org/10.1038/s41368-021-00146-0](https://doi.org/10.1038/s41368-021-00146-0).

### Publicações associadas aos conjuntos do curso


9. GRACIANO, R. C. D.; OLIVEIRA, R. S.; SANTOS, I. M.; YAZBECK, G. M. Genomic Resources for *Salminus brasiliensis*. *Frontiers in Genetics*, v. 13, artigo 855718, 2022. [https://doi.org/10.3389/fgene.2022.855718](https://doi.org/10.3389/fgene.2022.855718).

10. SOUZA, G. M.; VAN SLUYS, M.-A.; LEDGER, T.; et al. Assembly of the 373k gene space of the polyploid sugarcane genome reveals reservoirs of functional diversity in the world's leading biomass crop. *GigaScience*, v. 8, n. 12, artigo giz129, 2019. [https://doi.org/10.1093/gigascience/giz129](https://doi.org/10.1093/gigascience/giz129).

11. BARBOSA, M. S. R.; et al. The genome sequence of the açaí berry (*Euterpe oleracea* Mart.) and RNA-Seq analysis of the fruit ripening. *Genome*, v. 69, p. 1–14, 2026. [https://doi.org/10.1139/gen-2025-0105](https://doi.org/10.1139/gen-2025-0105).

12. WEBER, P.; KÜNSTNER, A.; HESS, J.; et al. Therapy-Related Transcriptional Subtypes in Matched Primary and Recurrent Head and Neck Cancer. *Clinical Cancer Research*, v. 28, n. 5, p. 1038–1052, 2022. [https://doi.org/10.1158/1078-0432.CCR-21-2244](https://doi.org/10.1158/1078-0432.CCR-21-2244).

13. SBAGHDI, T.; GARNEAU, J. R.; YERSIN, S.; et al. The Response of the Honey Bee Gut Microbiota to *Nosema ceranae* Is Modulated by the Probiotic *Pediococcus acidilactici* and the Neonicotinoid Thiamethoxam. *Microorganisms*, v. 12, n. 1, artigo 192, 2024. [https://doi.org/10.3390/microorganisms12010192](https://doi.org/10.3390/microorganisms12010192).

14. CABRAL, L.; PERSINOTI, G. F.; PAIXÃO, D. A. A.; et al. Gut microbiome of the largest living rodent harbors unprecedented enzymatic systems to degrade plant polysaccharides. *Nature Communications*, v. 13, artigo 629, 2022. [https://doi.org/10.1038/s41467-022-28310-y](https://doi.org/10.1038/s41467-022-28310-y).

15. SCACCIA, N.; DA SILVA FONSECA, J. V.; MEGUEYA, A. L.; et al. Analysis of chlorhexidine, antibiotics and bacterial community composition in water environments from Brazil, Cameroon and Madagascar during the COVID-19 pandemic. *Science of the Total Environment*, v. 932, artigo 173016, 2024. [https://doi.org/10.1016/j.scitotenv.2024.173016](https://doi.org/10.1016/j.scitotenv.2024.173016).