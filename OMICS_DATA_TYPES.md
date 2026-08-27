<h1 align="center"> Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026): Descrição dos tipos de dados ômicos </h1>

<p align="center">
Laboratório Nacional de Biociências (LNBio) · Centro Nacional de Pesquisa em Energia e Materiais (CNPEM)
Laboratório Nacional de Biorrenováveis (LNBR) · Centro Nacional de Pesquisa em Energia e Materiais (CNPEM)
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

## Biodiversidade brasileira

Grande parte dos dados utilizados no TRAD2026 está associada à biodiversidade brasileira. O curso inclui espécies de interesse ecológico e agrícola, como o dorado, o bugio, a capivara, o açaí e a cana-de-açúcar. Há também conjuntos relacionados a microbiomas, ambientes aquáticos e saúde humana.

Entre os conjuntos selecionados, há dados públicos e resultados de pesquisas e colaborações científicas que envolveram equipes do Laboratório Nacional de Biorrenováveis (LNBR) e do Laboratório Nacional de Biociências (LNBio). Essa combinação aproxima o treinamento de situações reais de pesquisa desenvolvidas no CNPEM.

Esses dados permitem trabalhar com perguntas científicas reais e observar como as mesmas práticas de organização, controle de qualidade e reprodutibilidade podem ser aplicadas a diferentes áreas da biologia.

## Referências e leituras complementares

1. BIÃO, L. F. Ciências Ômicas: Saindo do Zero. *Revista Blog Profissão Biotec*, v. 12, 2025. Disponível em: [https://profissaobiotec.com.br/ciencias-omicas-saindo-do-zero/](https://profissaobiotec.com.br/ciencias-omicas-saindo-do-zero/). Acesso em: 17 ago. 2026.

2. UNIVERSIDADE DE SÃO PAULO. O papel das ciências ômicas na compreensão dos distúrbios neurológicos. *Portal USP São Carlos*, 6 set. 2024. Disponível em: [https://saocarlos.usp.br/o-papel-das-ciencias-omicas-na-compreensao-dos-disturbios-neurologicos/](https://saocarlos.usp.br/o-papel-das-ciencias-omicas-na-compreensao-dos-disturbios-neurologicos/). Acesso em: 17 ago. 2026.

3. HU, T.; CHITNIS, N.; MONOS, D.; DINH, A. Next-generation sequencing technologies: an overview. *Human Immunology*, v. 82, n. 11, p. 801-811, 2021. [https://doi.org/10.1016/j.humimm.2021.02.012](https://doi.org/10.1016/j.humimm.2021.02.012).

4. LIU, Y.-X.; QIN, Y.; CHEN, T.; et al. A practical guide to amplicon and metagenomic analysis of microbiome data. *Protein & Cell*, v. 12, n. 5, p. 315-330, 2021. [https://doi.org/10.1007/s13238-020-00724-8](https://doi.org/10.1007/s13238-020-00724-8).

5. WEINROTH, M. D.; BELK, A. D.; DEAN, C.; et al. Considerations and best practices in animal science 16S ribosomal RNA gene sequencing microbiome studies. *Journal of Animal Science*, v. 100, n. 2, artigo skab346, 2022. [https://doi.org/10.1093/jas/skab346](https://doi.org/10.1093/jas/skab346).

6. KIM, N.; MA, J.; KIM, W.; et al. Genome-resolved metagenomics: a game changer for microbiome medicine. *Experimental & Molecular Medicine*, v. 56, p. 1501-1512, 2024. [https://doi.org/10.1038/s12276-024-01262-7](https://doi.org/10.1038/s12276-024-01262-7).

7. HONG, M.; TAO, S.; ZHANG, L.; et al. RNA sequencing: new technologies and applications in cancer research. *Journal of Hematology & Oncology*, v. 13, artigo 166, 2020. [https://doi.org/10.1186/s13045-020-01005-x](https://doi.org/10.1186/s13045-020-01005-x).

8. LI, X.; WANG, C.-Y. From bulk, single-cell to spatial RNA sequencing. *International Journal of Oral Science*, v. 13, artigo 36, 2021. [https://doi.org/10.1038/s41368-021-00146-0](https://doi.org/10.1038/s41368-021-00146-0).
