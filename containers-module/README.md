# Módulo II - Containers: Controle de ambientes e reprodutibilidade

**Containers com Singularity / Apptainer para Bioinformática**

Material de leitura com os conceitos trabalhados durante o treinamento. Para a parte prática (instalação, exercícios e comandos passo a passo), use o [*Roteiro Teórico-Prático*](roteiro-de-aula-pratica.md) que acompanha este material.

---

## Índice

1. [Ambientes contidos e reprodutibilidade](#1-ambientes-contidos-e-reprodutibilidade)
2. [O que são containers e sua finalidade](#2-o-que-são-containers-e-sua-finalidade)
3. [O que é Singularity / Apptainer](#3-o-que-é-singularity--apptainer)
4. [Como um container funciona](#4-como-um-container-funciona)
5. [Singularity × Docker](#5-singularity--docker)
6. [Construindo seu próprio container](#6-construindo-seu-próprio-container)
7. [Baixando containers prontos](#7-baixando-containers-prontos)
8. [Boas práticas](#8-boas-práticas)
9. [Glossário](#glossário)
10. [Referências](#referências)

---

## 1. Ambientes contidos e reprodutibilidade

### O problema

Quem trabalha com dados conhece a frase *"…mas funciona na minha máquina"*. Um mesmo script pode produzir resultados diferentes — ou simplesmente não rodar — quando se muda o ambiente ou o computador. As causas são recorrentes:

- **Sistemas diferentes:** o notebook, o cluster e a máquina do revisor rodam sistemas operacionais e versões de kernel distintos.
- **Inferno de dependências:** bibliotecas, compiladores e versões de pacotes que entram em conflito.
- **Instalação frágil:** horas de configuração manual que quebram na próxima atualização do sistema.
- **Ciência não reproduzível:** sem o ambiente exato, ninguém consegue repetir a análise meses ou anos depois.

Em análise de dados e, na bioinformática isso é especialmente grave: pipelines encadeiam dezenas de ferramentas, cada uma com suas dependências, e um resultado só tem valor científico se puder ser reproduzido.

### O que é um "ambiente contido"

Um **ambiente contido** empacota tudo de que a análise precisa — sistema operacional base, bibliotecas, ferramentas e configurações — em uma unidade isolada e portátil. Em vez de instalar cada peça "na mão" em cada máquina, você carrega o ambiente inteiro junto com o código.

Containers dão quatro garantias que sustentam a reprodutibilidade:

| Pilar | O que significa |
|---|---|
| **Ambiente empacotado** | SO, bibliotecas, versões e configurações reunidos em uma única imagem. |
| **Isolamento** | O que roda dentro não interfere no host nem em outras ferramentas — fim dos conflitos de versão. |
| **Imutabilidade** | A imagem é somente-leitura: comporta-se de forma idêntica em qualquer máquina e no futuro. |
| **Proveniência** | A *receita* que descreve a imagem é legível, versionável e auditável — documenta como o ambiente foi construído. |

A ideia central, em uma frase: **mesmo ambiente → mesmos resultados**, hoje, no cluster e daqui a cinco anos.

### Níveis de reprodutibilidade

A reprodutibilidade não é tudo-ou-nada; existe um espectro, do mais frágil ao mais robusto:

- **Nível 0 — README:** instruções manuais de instalação. Depende de o leitor conseguir reproduzir tudo à mão; quebra com facilidade.
- **Nível 1 — Gerenciador de ambiente:** `conda`/`venv` fixam as versões dos pacotes, mas ainda dependem do sistema operacional do host.
- **Nível 2 — Container (`.sif`):** o ambiente completo, isolado e portátil, empacotado numa imagem. **É o foco desta aula.**
- **Nível 3 — Container + workflow versionado:** o `.sif` somado a um gerenciador de workflow (Snakemake/Nextflow), controle de versão (Git) e arquivamento com identificador persistente (DOI). Reprodutibilidade total.

Cada nível "empacota" mais do ambiente e torna a análise mais fácil de repetir.

---

## 2. O que são containers e sua finalidade

### Definição

Um **container** empacota, em uma única unidade, o **código + as dependências + as bibliotecas + as configurações do ambiente**. Esse pacote roda de forma **idêntica** em qualquer máquina que tenha o runtime de containers instalado — seja o seu notebook, o cluster HPC ou o computador de outro pesquisador.

### A analogia do contêiner de carga

O nome não é por acaso. Navios, trens e caminhões transportam a mesma caixa metálica padronizada: não importa o que há dentro, o transporte é sempre igual, porque a *interface externa* é padronizada. Software em container segue a mesma lógica — o "ambiente" viaja junto, empacotado e padronizado, e a máquina que o executa não precisa saber o que há lá dentro.

### Para que servem (finalidade)

- **Portabilidade:** mover uma análise entre máquinas sem reinstalar nada.
- **Reprodutibilidade:** garantir que a mesma imagem produza os mesmos resultados ao longo do tempo.
- **Isolamento:** rodar ferramentas com dependências conflitantes lado a lado, sem interferência.
- **Compartilhamento:** distribuir um ambiente pronto para colegas, revisores ou para o material suplementar de um artigo.
- **Escalabilidade:** executar a mesma imagem em centenas de nós de um cluster, com o mesmo comportamento.

Em bioinformática, containers são hoje o padrão para empacotar ferramentas de alinhamento, chamada de variantes, montagem de genomas, análise de expressão e praticamente qualquer etapa de um pipeline.

---

## 3. O que é Singularity / Apptainer

**Singularity** (e o seu sucessor **Apptainer**) é um sistema de containers projetado desde o início para **computação científica e ambientes de HPC (High-Performance Computing)**, onde o Docker tradicionalmente não se encaixa.

### Por que existe uma ferramenta separada?

Três características o tornam adequado à ciência:

1. **Feito para HPC.** Roda como um usuário comum, **sem daemon** e **sem privilégios de root** — justamente o que o Docker exige e o que administradores de clusters compartilhados não permitem.
2. **Imagem = um único arquivo.** Toda a imagem vira um arquivo `.sif` (*Singularity Image Format*): fácil de mover, versionar, arquivar e anexar a um artigo.
3. **Integra com o cluster.** Conversa naturalmente com escalonadores como o SLURM, com MPI e com GPUs, encaixando-se nos fluxos de trabalho existentes.

### Singularity → Apptainer

Em 2021, o projeto de código aberto foi doado à **Linux Foundation** e renomeado para **Apptainer**. Na prática, os comandos são quase idênticos: onde você via `singularity`, pode usar `apptainer`. Ambos os nomes ainda circulam (há também a versão comercial "SingularityCE", da Sylabs), mas os conceitos desta apostila valem para os dois.

> **Resumo:** Singularity/Apptainer é a ferramenta de containers que roda com segurança em máquinas compartilhadas e produz uma imagem que é um único arquivo portátil.

---

## 4. Como um container funciona

### Compartilhando o kernel — a diferença para uma Máquina Virtual

A forma mais clara de entender um container é compará-lo a uma **máquina virtual (VM)**:

| Aspecto | Máquina Virtual | Container |
|---|---|---|
| **O que virtualiza** | O hardware inteiro; cada VM carrega um SO completo. | Nada — **compartilha o kernel** do host e empacota só o necessário. |
| **Peso** | Vários gigabytes; consome muita RAM/CPU. | Megabytes; pouco overhead. |
| **Inicialização** | Minutos (como ligar outro computador). | Segundos (como abrir um programa). |
| **Isolamento** | Muito forte, mas caro em recursos. | Suficiente para a maioria dos usos científicos, com custo baixo. |

A VM emula uma máquina completa; o container apenas **isola um processo** que usa o kernel do sistema hospedeiro. Por isso o container é leve e rápido.

### Imagem × instância em execução

- A **imagem** (`.sif`) é o pacote estático, **somente-leitura** e imutável.
- Quando você a executa, o runtime cria uma **instância** — um processo isolado — a partir dela. Como a imagem não muda, toda execução parte exatamente do mesmo estado.

### Isolamento e acesso aos dados

O container tem seu próprio sistema de arquivos (o conteúdo da imagem), separado do host. Por padrão, porém, o Singularity/Apptainer **monta automaticamente** algumas pastas do host — normalmente o seu diretório pessoal (`$HOME`), o `/tmp` e o diretório de trabalho atual — para que você acesse seus dados sem esforço. Para expor outras pastas, usa-se o **bind mount** (montar uma pasta do host em um caminho interno do container).

### Modelo de segurança

No Singularity/Apptainer, um comando executado dentro do container roda **com as permissões do próprio usuário** que o iniciou. Um usuário comum não consegue escalar privilégios de dentro do container. É essa propriedade que torna a ferramenta segura para clusters multiusuário — e é a principal diferença de arquitetura em relação ao Docker.

---

## 5. Singularity × Docker

Docker e Singularity resolvem o mesmo problema (empacotar ambientes), mas com **focos diferentes**. Não é uma rivalidade: cada um brilha em um contexto.

| Aspecto | Docker | Singularity / Apptainer |
|---|---|---|
| **Execução** | Um *daemon* em segundo plano, executado como root. | Sem daemon; roda como um programa comum. |
| **Privilégios** | Exige `sudo`/admin — barrado em clusters compartilhados. | Roda **sem privilégios de root**; ideal para HPC. |
| **Formato da imagem** | Camadas guardadas num *store* local; portar exige export/save. | Um **único arquivo `.sif`**, fácil de mover e versionar. |
| **Acesso aos dados** | Isolado por padrão; ver o `$HOME` exige configuração. | Monta `$HOME`, `/tmp` e a pasta atual automaticamente. |
| **Onde brilha** | Microsserviços, aplicações web, CI/CD. | HPC, ciência reprodutível, clusters compartilhados. |

### Compatibilidade

O ponto mais importante: **os dois se complementam**. O Singularity/Apptainer consegue **rodar imagens Docker** diretamente de um registro, convertendo-as para `.sif` no ato:

```bash
singularity build bio.sif docker://ubuntu:22.04
```

Assim, todo o vasto ecossistema de imagens Docker (incluindo os BioContainers) permanece acessível a quem usa Singularity. Na prática: use Docker para desenvolvimento e CI; use Singularity para executar em HPC.

---

## 6. Construindo seu próprio container

### Vocabulário essencial

| Termo | Significado |
|---|---|
| **Receita (`.def`)** | Arquivo de texto com as instruções de como construir a imagem — a "lista de ingredientes". |
| **Imagem (`.sif`)** | O pacote final: imutável, executável e autocontido. É o que você roda e compartilha. |
| **Build** | O processo que transforma a receita `.def` na imagem `.sif`. |
| **Bootstrap / base** | A imagem de origem de onde você parte (ex.: `docker://ubuntu:22.04`). |
| **Bind mount** | Montar pastas do host dentro do container para acessar seus dados. |

### Anatomia de um arquivo `.def`

A receita tem um **cabeçalho** e várias **seções**, cada uma iniciada por `%`:

- **Cabeçalho** (`Bootstrap:` / `From:`) — define a imagem base de onde partir.
- **`%files`** — copia arquivos do host para dentro da imagem (na construção).
- **`%post`** — comandos executados **durante o build**: instalar softwares e dependências.
- **`%environment`** — variáveis de ambiente definidas **em tempo de execução**.
- **`%runscript`** — o que roda ao chamar `singularity run`.
- **`%labels`** — metadados (autor, versão, descrição).
- **`%help`** — texto de ajuda, exibido por `singularity run-help`.

Exemplo comentado (samtools + bcftools):

```singularity
Bootstrap: docker
From: ubuntu:22.04

%labels
    Author   SeuNome
    Version  1.0

%post
    apt-get update
    apt-get install -y samtools bcftools

%environment
    export LC_ALL=C

%runscript
    exec samtools "$@"

%help
    Container com samtools + bcftools.
```

### Ambientes Conda isolados dentro do container

Um padrão poderoso em bioinformática é instalar um **ambiente Conda** dentro do container. As duas camadas são complementares: o **container** garante o SO e a portabilidade; o **Conda** instala centenas de ferramentas (canal **Bioconda**) com **versões exatas**, sem compilar nada.

O ambiente é descrito por um `environment.yml` versionável:

```yaml
name: bioenv
channels: [conda-forge, bioconda]
dependencies:
  - samtools=1.21
  - bcftools=1.21
```

E instalado na seção `%post`. O **truque de "ativação"**: em vez de `conda activate` (que depende de *hooks* de shell e não funciona bem em scripts), coloca-se o diretório `bin` do ambiente no `PATH`, dentro de `%environment`:

```singularity
%environment
    export PATH=/opt/conda/envs/bioenv/bin:$PATH
```

Assim o ambiente já vem **ativo** — cada `exec`/`run` usa automaticamente as versões fixadas.

### Do `.def` ao `.sif`: o build

O comando de construção segue o padrão `singularity build <saída.sif> <receita.def>`:

- **A partir da receita:** `sudo singularity build bio.sif bio.def`
- **Sem root, em cluster HPC:** `singularity build --fakeroot bio.sif bio.def`
- **Direto de um registro, sem `.def`:** `singularity build bio.sif docker://ubuntu:22.04`

### Executando o container

| Comando | O que faz |
|---|---|
| **`run`** | Executa o `%runscript` — o comando padrão da imagem. |
| **`exec`** | Roda um comando arbitrário dentro do container. |
| **`shell`** | Abre um shell interativo dentro do container. |
| **`--bind`** | Monta pastas do host para acessar seus dados (ex.: `--bind /dados:/mnt`). |

### O fluxo completo

**`bio.def`** (você escreve a receita) → **`build`** (constrói a imagem) → **`bio.sif`** (imagem pronta) → **`run`/`exec`** (roda a análise).

Como a receita `.def` é pequena e legível, versione-a no Git: a partir dela, a imagem pode ser reconstruída de forma idêntica sempre que necessário.

---

## 7. Baixando containers prontos

Você quase nunca precisa construir do zero — a comunidade já empacotou milhares de ferramentas. Vale conhecer as principais fontes.

### Repositórios de imagens

- **Docker Hub** — imagens gerais e de organizações. Muitas mantêm tags limpas e versionadas (ex.: a StaPH-B para genômica):
  ```bash
  apptainer pull docker://staphb/samtools:1.21
  ```
- **BioContainers (Quay.io)** — o projeto empacota **automaticamente** cada pacote do Bioconda como uma imagem. O endereço segue o padrão `docker://quay.io/biocontainers/<ferramenta>:<versão>--<hash>`. A tag exata (o "hash" de build) muda a cada reconstrução, então convém copiá-la da aba *Tags* no Quay.io:
  ```bash
  apptainer pull docker://quay.io/biocontainers/bcftools:1.21--h8b25389_0
  ```
- **Galaxy Depot** — mantém os `.sif` **já convertidos** dos BioContainers, ideais para HPC (sem conversão local):
  ```bash
  apptainer pull https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0
  ```

### Seqera Containers — gerar sob demanda

A plataforma **[seqera.io/containers](https://seqera.io/containers/)** oferece uma abordagem diferente: em vez de procurar imagens prontas, você **escolhe pacotes Conda/PyPI** numa interface web e a plataforma **constrói a imagem na hora** (por trás, usa o serviço *Wave*), devolvendo uma URI de imagem Docker **ou** Singularity.

Fluxo resumido:

1. Escolha os pacotes (ex.: `samtools` + `bcftools` — vão para a mesma imagem).
2. Selecione o formato **Singularity** e a arquitetura **linux/amd64**.
3. Clique em **Get Container** e copie a URI que a plataforma devolve.
4. Puxe no seu computador — para Singularity, a URI usa o protocolo **ORAS**:
   ```bash
   apptainer pull oras://community.wave.seqera.io/library/samtools:<id>
   ```

Vantagens: é **gratuito**, não exige escrever `Dockerfile` nem `.def`, faz **varredura de segurança** (Trivy) e ainda permite baixar o `.sif` diretamente pelo navegador. É, essencialmente, a mesma ideia da seção 6 (Conda no container), automatizada.

> **Reprodutibilidade:** builds sob demanda são convenientes, mas para proveniência a longo prazo **fixe a URI exata** que você usou e **arquive o `.sif`**.

### `pull` × `build`

- **`pull`** baixa uma imagem pronta (convertendo de Docker para `.sif` quando necessário).
- **`build`** também aceita puxar de um registro (`docker://…`), mas permite ir além, aplicando uma receita `.def`.

---

## 8. Boas práticas

Recomendações para que os seus containers sejam realmente reprodutíveis e seguros:

- **Fixe as versões.** Escreva `ubuntu:22.04` e `samtools=1.21`, nunca `latest`. A reprodutibilidade depende disso — `latest` muda com o tempo.
- **Documente a imagem.** Preencha `%labels` e `%help`. Seu "eu" do futuro e seus colegas vão agradecer.
- **Versione a receita.** Guarde o `.def` (e o `environment.yml`) no Git. O `.sif` é grande e não precisa ir para o repositório; a receita é pequena e reconstrói tudo.
- **Teste antes de usar.** Rode `singularity test` / `run-help` e valide a ferramenta antes de colocá-la em produção.
- **Prefira bases enxutas.** Imagens menores constroem mais rápido, ocupam menos espaço e têm menor superfície de vulnerabilidades.
- **Cuidado com bind mounts.** Monte apenas as pastas necessárias e, quando possível, em modo somente-leitura (`:ro`); evite expor dados sensíveis.
- **Arquive para reprodutibilidade real.** Para publicação, deposite o `.sif` (ou a URI exata da imagem) num local persistente, de forma que qualquer pessoa reproduza o ambiente.

---

## Glossário

- **Apptainer** — nome atual do projeto Singularity de código aberto, sob a Linux Foundation desde 2021.
- **Bind mount** — montagem de uma pasta do host em um caminho dentro do container.
- **Bioconda** — canal do Conda especializado em ferramentas de bioinformática.
- **BioContainers** — projeto que empacota pacotes Bioconda como imagens de container.
- **Bootstrap** — diretiva do `.def` que define a origem da imagem base.
- **Container** — pacote isolado e portátil com código, dependências e ambiente.
- **`.def`** — arquivo-receita que descreve como construir uma imagem.
- **Daemon** — serviço em segundo plano; o Docker usa um, o Singularity não.
- **HPC** — *High-Performance Computing*; clusters de alto desempenho, tipicamente compartilhados.
- **Imagem** — o pacote estático e imutável a partir do qual containers são executados.
- **Kernel** — núcleo do sistema operacional; compartilhado entre host e container.
- **ORAS** — protocolo para distribuir artefatos (como imagens `.sif`) em registros OCI.
- **`.sif`** — *Singularity Image Format*; a imagem como um único arquivo.
- **Wave** — serviço da Seqera que constrói imagens de container sob demanda.

---

## Referências

- Apptainer — Documentação: https://apptainer.org/docs/
- Apptainer — Guia rápido: https://apptainer.org/docs/user/main/quick_start.html
- BioContainers: https://biocontainers.pro/
- Galaxy Project — depósito de imagens Singularity: https://depot.galaxyproject.org/singularity/
- Seqera Containers: https://seqera.io/containers/
- Conda / Bioconda: https://bioconda.github.io/

---

*Este material resume a teoria. Para colocar a mão na massa — instalar, baixar, construir e executar containers no seu computador — siga o Roteiro Teórico-Prático que acompanha o material.*
