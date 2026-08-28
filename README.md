# Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026): Git, Containers e Nextflow

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22071921.svg)](https://doi.org/10.5281/zenodo.22071921)

Materiais do Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026), organizado pelas equipes do LNBio/CNPEM e do LNBR/CNPEM.

O treinamento aborda práticas fundamentais de reprodutibilidade computacional, distribuídas em três módulos independentes:
1. **Git**: versionamento de código e colaboração.
2. **Containers**: Singularity/Apptainer para ambientes reprodutíveis.
3. **Nextflow**: orquestração de pipelines de análise de dados.

## Conjuntos de dados

As atividades do TRAD2026 utilizam conjuntos de dados de genômica, transcriptômica, metagenômica *shotgun* e sequenciamento de amplicons do gene 16S rRNA.

A origem, os acessos públicos e a organização desses dados estão descritos em [Descrição dos conjuntos de dados do TRAD2026](DATASETS.md) e disponíveis em [https://zenodo.org/records/22071921](https://zenodo.org/records/22071921) (DOI: [10.5281/zenodo.22071921](https://doi.org/10.5281/zenodo.22071921)).

## Datas

| Módulo | Data | Horário | Local |
|--------|------|---------|-------|
| Git | 04/09 | 8h15–13h | Sala 946E1 (Sirius) |
| Containers | 11/09 | 8h15–13h | Sala 946E1 (Sirius) |
| Nextflow | 18/09 | 8h15–13h | Sala 946E1 (Sirius) |

## Como baixar

```bash
git clone https://github.com/cnpem/TRAD2026.git
cd TRAD2026
```

Em seguida, entre no diretório do módulo desejado e siga o material correspondente.

## Organização do repositório

O repositório está organizado em três módulos de treinamento e em arquivos complementares sobre os conjuntos de dados utilizados no curso:

```text
TRAD2026/
├── containers-module/            # Material do módulo de containers
├── git-module/                   # Material do módulo de Git
├── nextflow-module/              # Material do módulo de Nextflow
├── .gitignore                    # Arquivos e diretórios ignorados pelo Git
├── DATASETS_METADATA.xlsx        # Metadados detalhados dos conjuntos de dados
├── DATASETS.md                   # Descrição dos conjuntos de dados do curso
├── OMICS_DATA_TYPES.md           # Introdução aos principais tipos de dados ômicos
└── README.md                     # Apresentação geral do treinamento
```

Os diretórios `git-module/`, `containers-module/` e `nextflow-module/` contêm os materiais e exercícios correspondentes a cada módulo do treinamento.

O arquivo [DATASETS.md](DATASETS.md) apresenta os conjuntos de dados selecionados para as atividades, enquanto a planilha [DATASETS_METADATA.xlsx](DATASETS_METADATA.xlsx) reúne informações mais detalhadas sobre sua origem, seus identificadores e suas características.

O arquivo [OMICS_DATA_TYPES.md](OMICS_DATA_TYPES.md) oferece uma breve introdução aos dados ômicos abordados no curso, explicando o que são esses dados e quais tipos de informação biológica podem ser obtidos a partir deles. Sua leitura é especialmente recomendada para participantes que ainda não trabalharam com esse tipo de dado, pois apresenta conceitos que serão necessários para compreender as etapas de análise e os resultados explorados posteriormente nos módulos práticos.


## Autores

Material desenvolvido pelas equipes do LNBio/CNPEM e LNBR/CNPEM:

- João V. S. Guerra ([@jvsguerra](https://github.com/jvsguerra)) — LNBio/CNPEM
- Joaquim M. Junior ([@jmartinsjrbr](https://github.com/jmartinsjrbr)) — LNBR/CNPEM
- Monyque K. P. Silva ([@kpsmonyque](https://github.com/kpsmonyque)) — LNBR/CNPEM
- Nilson A. R. Coimbra ([@nilsoncoimbra](https://github.com/nilsoncoimbra)) — LNBio/CNPEM

---
