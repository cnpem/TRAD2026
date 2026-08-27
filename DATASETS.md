<h1 align="center"> Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026): Descrição dos conjuntos de dados ômicos </h1>

<p align="center">
Laboratório Nacional de Biociências (LNBio) · Centro Nacional de Pesquisa em Energia e Materiais (CNPEM)
Laboratório Nacional de Biorrenováveis (LNBR) · Centro Nacional de Pesquisa em Energia e Materiais (CNPEM)
</p>

---

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

## Acesso aos dados

Os arquivos utilizados nas atividades estão disponíveis no Zenodo, em [https://zenodo.org/records/22071921](https://zenodo.org/records/22071921) (DOI: [10.5281/zenodo.22071921](https://doi.org/10.5281/zenodo.22071921)), e podem ser baixados diretamente do repositório do TRAD2026.

Informações sobre a origem, os identificadores e as características dos conjuntos podem ser consultadas na planilha de dados do TRAD2026, a qual está disponível neste diretório com o nome [DATASETS_METADATA.xlsx](DATASETS_METADATA.xlsx).

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
.
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

---

## Referências bibliográficas

1. GRACIANO, R. C. D.; OLIVEIRA, R. S.; SANTOS, I. M.; YAZBECK, G. M. Genomic Resources for *Salminus brasiliensis*. *Frontiers in Genetics*, v. 13, artigo 855718, 2022. [https://doi.org/10.3389/fgene.2022.855718](https://doi.org/10.3389/fgene.2022.855718).

2. SOUZA, G. M.; VAN SLUYS, M.-A.; LEDGER, T.; et al. Assembly of the 373k gene space of the polyploid sugarcane genome reveals reservoirs of functional diversity in the world's leading biomass crop. *GigaScience*, v. 8, n. 12, artigo giz129, 2019. [https://doi.org/10.1093/gigascience/giz129](https://doi.org/10.1093/gigascience/giz129).

3. BARBOSA, M. S. R.; et al. The genome sequence of the açaí berry (*Euterpe oleracea* Mart.) and RNA-Seq analysis of the fruit ripening. *Genome*, v. 69, p. 1–14, 2026. [https://doi.org/10.1139/gen-2025-0105](https://doi.org/10.1139/gen-2025-0105).

4. WEBER, P.; KÜNSTNER, A.; HESS, J.; et al. Therapy-Related Transcriptional Subtypes in Matched Primary and Recurrent Head and Neck Cancer. *Clinical Cancer Research*, v. 28, n. 5, p. 1038–1052, 2022. [https://doi.org/10.1158/1078-0432.CCR-21-2244](https://doi.org/10.1158/1078-0432.CCR-21-2244).

5. SBAGHDI, T.; GARNEAU, J. R.; YERSIN, S.; et al. The Response of the Honey Bee Gut Microbiota to *Nosema ceranae* Is Modulated by the Probiotic *Pediococcus acidilactici* and the Neonicotinoid Thiamethoxam. *Microorganisms*, v. 12, n. 1, artigo 192, 2024. [https://doi.org/10.3390/microorganisms12010192](https://doi.org/10.3390/microorganisms12010192).

6. CABRAL, L.; PERSINOTI, G. F.; PAIXÃO, D. A. A.; et al. Gut microbiome of the largest living rodent harbors unprecedented enzymatic systems to degrade plant polysaccharides. *Nature Communications*, v. 13, artigo 629, 2022. [https://doi.org/10.1038/s41467-022-28310-y](https://doi.org/10.1038/s41467-022-28310-y).

7. SCACCIA, N.; DA SILVA FONSECA, J. V.; MEGUEYA, A. L.; et al. Analysis of chlorhexidine, antibiotics and bacterial community composition in water environments from Brazil, Cameroon and Madagascar during the COVID-19 pandemic. *Science of the Total Environment*, v. 932, artigo 173016, 2024. [https://doi.org/10.1016/j.scitotenv.2024.173016](https://doi.org/10.1016/j.scitotenv.2024.173016).
