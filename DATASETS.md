<h1 align="center">Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026): descrição dos conjuntos de dados ômicos</h1>

<p align="center">
Laboratório Nacional de Biociências (LNBio) · Centro Nacional de Pesquisa em Energia e Materiais (CNPEM)
<br>
Laboratório Nacional de Biorrenováveis (LNBR) · Centro Nacional de Pesquisa em Energia e Materiais (CNPEM)
</p>

---

## Conjuntos de dados do TRAD2026

Os conjuntos apresentados a seguir serão explorados em diferentes atividades do curso.

| Categoria | Conjunto de dados | Organismo ou contexto | Tipo de dado |
| --- | --- | --- | --- |
| Genômica | Dourado | *Salminus brasiliensis* | WGS |
| Genômica | Bugio-preto | *Alouatta caraya* | WGS |
| Genômica | Flor-de-Carajás | *Ipomoea cavalcantei* | WGS |
| Transcriptômica | Açaí | *Euterpe oleracea* | RNA-seq |
| Transcriptômica | Câncer de cabeça e pescoço | HNSCC, amostras humanas | RNA-seq |
| Metagenômica | Microbiota de abelhas | Microbiota intestinal de *Apis mellifera* | Metagenômica *shotgun* |
| Metagenômica | Microbiota de capivara | Microbiota intestinal de *Hydrochoerus hydrochaeris* | Metagenômica *shotgun* |
| Amplicon | Microbiota da capivara | Microbiota intestinal de *Hydrochoerus hydrochaeris* | Amplicon 16S rRNA |
| Amplicon | Água e efluentes | Amostras brasileiras coletadas em São Paulo | Amplicon 16S rRNA |

Ao todo, o TRAD2026 reúne **nove conjuntos de dados**: três genômicos, dois transcriptômicos, dois metagenômicos *shotgun* e dois conjuntos de amplicon 16S.

### Origem e seleção dos dados

Os códigos `PRJNA` identificam BioProjects, enquanto cada código `SRR` identifica um conjunto de leituras (DNA ou RNA) depositado no Sequence Read Archive (SRA). Os estudos de origem possuem conjuntos de dados mais amplos; para o TRAD2026, foram selecionados apenas alguns acessos `SRR` representativos de cada estudo.

O termo **subset**, neste documento, refere-se à seleção de determinados acessos `SRR`. Não houve subamostragem nem redução do número de reads dentro dos acessos selecionados: os arquivos utilizados correspondem aos conjuntos completos de leituras depositados no SRA.

| Conjunto | BioProject ou estudo de origem | Subset utilizado no TRAD2026 | Publicação associada |
| --- | --- | --- | --- |
| Dourado | `PRJNA792751`, `PRJNA1433447` e `PRJNA1433448` | `SRR17407720`, `SRR37670351` e `SRR37671906` | Graciano et al. (2022), para `SRR17407720`; projetos de 2026 ainda sem artigo associado |
| Bugio-preto | `PRJNA1404690` | `SRR38321363` | BioProject de 2026 ainda sem artigo associado |
| Flor-de-Carajás | `PRJNA1327434` e `PRJNA1327435`; `SRP620331` | `SRR35396924` | Canesin et al. (2026) |
| Açaí | `PRJNA1265274`, `PRJNA1265420` e `PRJNA1262982` | `SRR33581420`, `SRR33581421`, `SRR33581422` e `SRR33581424` | Barbosa et al. (2026) |
| HNSCC | `PRJNA727315`; `GSE173855` | `SRR14428034`, `SRR14428035`, `SRR14428042` e `SRR14428043` | Weber et al. (2022) |
| Microbiota de abelhas | `PRJNA977416` | `SRR24759596–SRR24759598` | Sbaghdi et al. (2024) |
| Metagenômica da capivara | `PRJNA563062` | `SRR11852046–SRR11852048` | Cabral et al. (2022) |
| 16S da capivara | `PRJNA563062` | `SRR11852069–SRR11852074` | Cabral et al. (2022) |
| 16S de água e efluentes | `PRJNA880881` | `SRR27211468–SRR27211473`, `SRR27211477`, `SRR27211486–SRR27211492`, `SRR27211499`, `SRR27211506–SRR27211512` e `SRR27211521–SRR27211522` | Scaccia et al. (2024) |

No conjunto de água e efluentes, foram selecionadas somente as 24 amostras brasileiras: seis amostras de água da Raia da USP, seis de efluente hospitalar do Hospital das Clínicas da FMUSP e 12 de efluentes urbanos de duas estações de tratamento de São Paulo. As coletas ocorreram entre janeiro e junho de 2022. Os amplicons foram sequenciados em Ion Torrent S5 no modo **single-end**; portanto, essas amostras não possuem pares R1 e R2.

O estudo de *Ipomoea cavalcantei* produziu duas montagens haplotípicas, depositadas sob os acessos `JBUPYS000000000` e `JBUPYT000000000`, além de dados brutos PacBio HiFi e Hi-C associados aos BioProjects `PRJNA1327434` e `PRJNA1327435` e ao BioSample `SAMN51280989`. No TRAD2026, será utilizado somente o acesso PacBio HiFi `SRR35396924`, gerado em uma plataforma PacBio Sequel IIe.

Os dados de açaí e bugio também foram produzidos com tecnologias de leituras longas.

## Acesso aos dados

Os arquivos selecionados para as atividades estão disponíveis no [Zenodo](https://zenodo.org/records/22071921), sob o DOI [10.5281/zenodo.22071921](https://doi.org/10.5281/zenodo.22071921), e podem ser baixados diretamente desse repositório.

Informações complementares sobre a origem, os identificadores e as características dos conjuntos podem ser consultadas na planilha [DATASETS_METADATA.xlsx](DATASETS_METADATA.xlsx), disponível neste diretório.

### Organização das pastas

Cada pasta corresponde a um conjunto biológico. As informações abaixo descrevem os dados selecionados para o curso: 

| Pasta | Abordagem | Características dos dados |
| --- | --- | --- |
| `16S_Hydrochoerus_hydrochaeris/` | Amplicon 16S rRNA | • **Contexto:** microbiota intestinal de capivara<br>• **Tecnologia:** Illumina<br>• **Organização das leituras:** paired-end<br>• **Dados selecionados:** 6 acessos SRR |
| `16S_Waterwaste/` | Amplicon 16S rRNA | • **Contexto:** amostras brasileiras de água e efluentes<br>• **Tecnologia:** Ion Torrent S5<br>• **Organização das leituras:** single-end<br>• **Dados selecionados:** 24 acessos SRR |
| `Alouatta_sp/` | Genômica/WGS | • **Contexto:** genoma do bugio-preto (*Alouatta caraya*)<br>• **Tecnologia:** Oxford Nanopore PromethION<br>• **Organização das leituras:** leituras longas não pareadas<br>• **Dados selecionados:** 1 acesso SRR |
| `Apis_mellifera/` | Metagenômica *shotgun* | • **Contexto:** microbiota intestinal de abelhas (*Apis mellifera*)<br>• **Tecnologia:** Illumina<br>• **Organização das leituras:** paired-end<br>• **Dados selecionados:** 3 acessos SRR |
| `Euterpe_oleracea/` | RNA-seq | • **Contexto:** transcriptoma de frutos de açaí (*Euterpe oleracea*)<br>• **Tecnologia:** Oxford Nanopore<br>• **Organização das leituras:** leituras longas não pareadas<br>• **Dados selecionados:** 4 acessos SRR |
| `HNSCC/` | RNA-seq | • **Contexto:** tumores humanos primários e recorrentes de cabeça e pescoço<br>• **Tecnologia:** Illumina<br>• **Organização das leituras:** paired-end<br>• **Dados selecionados:** 4 acessos SRR |
| `Ipomoea_cavalcantei/` | Genômica/WGS | • **Contexto:** genoma da flor-de-Carajás (*Ipomoea cavalcantei*)<br>• **Tecnologia:** PacBio Sequel IIe, com leituras HiFi<br>• **Organização das leituras:** leituras longas não pareadas<br>• **Dados selecionados:** 1 acesso SRR |
| `MG_Hydrochoerus_hydrochaeris/` | Metagenômica *shotgun* | • **Contexto:** microbiota intestinal de capivara (*Hydrochoerus hydrochaeris*)<br>• **Tecnologia:** Illumina<br>• **Organização das leituras:** paired-end<br>• **Dados selecionados:** 3 acessos SRR |
| `Salminus_brasiliensis/` | Genômica/WGS | • **Contexto:** genoma do dourado (*Salminus brasiliensis*)<br>• **Tecnologia:** Illumina<br>• **Organização das leituras:** paired-end<br>• **Dados selecionados:** 3 acessos SRR |

Nos conjuntos **paired-end**, cada acesso é representado por dois arquivos, geralmente identificados por `_1` e `_2` ou por `R1` e `R2`. Nos conjuntos **single-end** e nos conjuntos de leituras longas não pareadas, há apenas um arquivo de leitura por acesso SRR.

Os dados estão organizados da seguinte forma:

```text
.
├── 16S_Hydrochoerus_hydrochaeris/
├── 16S_Waterwaste/
├── Alouatta_sp/
├── Apis_mellifera/
├── Euterpe_oleracea/
├── HNSCC/
├── Ipomoea_cavalcantei/
├── MG_Hydrochoerus_hydrochaeris/
└── Salminus_brasiliensis/
```

---

## Referências bibliográficas

1. GRACIANO, R. C. D.; OLIVEIRA, R. S.; SANTOS, I. M.; YAZBECK, G. M. Genomic Resources for *Salminus brasiliensis*. *Frontiers in Genetics*, v. 13, artigo 855718, 2022. https://doi.org/10.3389/fgene.2022.855718.

2. CANESIN, L. E. C.; VILLAÇA, S. T.; MAGALHÃES, L.; et al. Diploid chromosome-level genome assembly of the Amazonian endemic morning glory *Ipomoea cavalcantei* D.F. Austin. *Scientific Data*, v. 13, artigo 972, 2026. https://doi.org/10.1038/s41597-026-07258-4.

3. BARBOSA, M. S. R.; et al. The genome sequence of the açaí berry (*Euterpe oleracea* Mart.) and RNA-Seq analysis of the fruit ripening. *Genome*, v. 69, p. 1–14, 2026. https://doi.org/10.1139/gen-2025-0105.

4. WEBER, P.; KÜNSTNER, A.; HESS, J.; et al. Therapy-Related Transcriptional Subtypes in Matched Primary and Recurrent Head and Neck Cancer. *Clinical Cancer Research*, v. 28, n. 5, p. 1038–1052, 2022. https://doi.org/10.1158/1078-0432.CCR-21-2244.

5. SBAGHDI, T.; GARNEAU, J. R.; YERSIN, S.; et al. The Response of the Honey Bee Gut Microbiota to *Nosema ceranae* Is Modulated by the Probiotic *Pediococcus acidilactici* and the Neonicotinoid Thiamethoxam. *Microorganisms*, v. 12, n. 1, artigo 192, 2024. https://doi.org/10.3390/microorganisms12010192.

6. CABRAL, L.; PERSINOTI, G. F.; PAIXÃO, D. A. A.; et al. Gut microbiome of the largest living rodent harbors unprecedented enzymatic systems to degrade plant polysaccharides. *Nature Communications*, v. 13, artigo 629, 2022. https://doi.org/10.1038/s41467-022-28310-y.

7. SCACCIA, N.; DA SILVA FONSECA, J. V.; MEGUEYA, A. L.; et al. Analysis of chlorhexidine, antibiotics and bacterial community composition in water environments from Brazil, Cameroon and Madagascar during the COVID-19 pandemic. *Science of the Total Environment*, v. 932, artigo 173016, 2024. https://doi.org/10.1016/j.scitotenv.2024.173016.
