# Módulo II - Containers: Controle de ambientes e reprodutibilidade

**Containers com Singularity / Apptainer para Bioinformática**

Este diretório reúne os materiais do módulo de **Containers** do **Treinamento de Reprodutibilidade para Anaĺise de Dados (TRAD2026)**. 
O módulo apresenta os conceitos de containers, como construí-los e utiliza-los bem como suas vantagens em relação aos demais tipos de ambientes, com conda, VM e Docker.

---

## Objetivos

Ao final do módulo, espera-se que os participantes sejam capazes de:

- Explicar reprodutibilidade computacional e por que ela é um problema científico, não apenas técnico.​;
- Diferenciar container, máquina virtual e ambiente Conda;
- Justificar o uso de Singularity/Apptainer em HPC em comparação com Docker;
- Obter imagens de repositórios públicos (DockerHub, BioContainers, quay.io) e converter para o formato SIF;
- Executar containers com run, exec e shell, compreendendo a diferença prática entre os três;
- Diagnosticar e corrigir um .def defeituoso;
- Escrever uma definition file completa e contruir sua própria imagem.

---

## Materiais

```text
.
├── apostila.pdf          # conceitos e fundamentos apresentados no módulo
├── atividades.md         # tutorial e roteiro da atividade prática
├── QUESTIONARIO.md       # questionário sobre os conceitos discutidos nesse módulo
├── README.md             # este arquivo
├── atividades/           # scripts utilizados no projeto prático
│   ├── scripts/          # scripts de execução das atividades do projeto prático
│   └── defs/             # Definition files que serão usados na atividade prática
|   └── qc_results/       # pasta para salvar os resultados da prática de containers
└── slides.pdf            # apresentação utilizada durante a aula expositiva
```
