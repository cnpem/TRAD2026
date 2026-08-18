# Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026): Git, Containers e Nextflow

Materiais do Treinamento em Reprodutibilidade para Análise de Dados (TRAD2026), organizado pelas equipes do LNBio/CNPEM e do LNBR/CNPEM.

O treinamento aborda práticas fundamentais de reprodutibilidade computacional, distribuídas em três módulos independentes:
1. **Git**: versionamento de código e colaboração.
2. **Containers**: Docker e Singularity/Apptainer para ambientes reprodutíveis.
3. **Nextflow**: orquestração de pipelines de análise de dados.

## Conjuntos de dados

As atividades do TRAD2026 utilizam conjuntos de dados de genômica, transcriptômica, metagenômica *shotgun* e sequenciamento de amplicons do gene 16S rRNA.

A origem, os acessos públicos e a organização desses dados no HPC Marvin estão descritos em [Descrição dos conjuntos de dados do TRAD2026](docs/DATASETS.md).

## Datas

| Módulo | Data | Horário | Local |
|--------|------|---------|-------|
| Git | 04/09 | 8h–13h | Sala 946E1 (Sirius) |
| Containers | 11/09 | 8h–13h | Sala 946E1 (Sirius) |
| Nextflow | 18/09 | 8h–13h | Sala 946E1 (Sirius) |

## Como baixar

```bash
git clone https://github.com/cnpem/TRAD2026.git
cd TRAD2026
```

Em seguida, entre no diretório do módulo desejado e siga o material correspondente.

## Organização do repositório

```text
TRAD2026/
├── git-module/          # Material do módulo de Git
├── containers-module/   # Material do módulo de containers
├── nextflow-module/     # Material do módulo de Nextflow
└── docs/                # Documentação e descrição dos dados
```

## Autores

Material desenvolvido pelas equipes do LNBio/CNPEM e LNBR/CNPEM:

- João V. S. Guerra ([@jvsguerra](https://github.com/jvsguerra)) — LNBio/CNPEM
- Joaquim M. Junior ([@jmartinsjrbr](https://github.com/jmartinsjrbr)) — LNBR/CNPEM
- Monyque K. P. Silva ([@kpsmonyque](https://github.com/kpsmonyque)) — LNBR/CNPEM
- Nilson A. R. Coimbra ([@nilsoncoimbra](https://github.com/nilsoncoimbra)) — LNBio/CNPEM

---
