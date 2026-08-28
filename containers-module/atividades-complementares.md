# Do Zero ao Container — Roteiro Teórico-Prático

**Singularity / Apptainer para Bioinformática**

Material de apoio para executar no seu próprio computador. Leia os conceitos, faça os exercícios na ordem e guarde este arquivo — ele complementa os slides da aula.

> **Convenção de comandos.** Vamos usar `apptainer` em todos os exemplos. Se no seu sistema o comando disponível for `singularity`, tudo funciona igual: basta trocar `apptainer` por `singularity`. Eles são praticamente intercambiáveis (o Apptainer é a continuação do Singularity na Linux Foundation desde 2021).

---

## Sumário

1. [Conceitos essenciais (resumo)](#1-conceitos-essenciais-resumo)
2. [Preparação do ambiente](#2-preparação-do-ambiente)
3. [Módulo 1 — Rodar containers prontos](#módulo-1--rodar-containers-prontos)
4. [Módulo 2 — Repositórios de imagens bioinformáticas](#módulo-2--repositórios-de-imagens-bioinformáticas)
5. [Módulo 3 — Seqera Containers (seqera.io/containers)](#módulo-3--seqera-containers)
6. [Módulo 4 — Construir a sua própria imagem (.def → .sif)](#módulo-4--construir-a-sua-própria-imagem)
7. [Módulo 5 — Configurar as seções do .def](#módulo-5--configurar-as-seções-do-def)
8. [Módulo 6 — Executar com os seus dados (bind mounts)](#módulo-6--executar-com-os-seus-dados)
9. [Módulo 7 — Ambientes Conda isolados dentro do container](#módulo-7--ambientes-conda-isolados-dentro-do-container)
10. [Desafio final](#desafio-final)
11. [Checklist de aprendizagem](#checklist-de-aprendizagem)
12. [Solução de problemas](#solução-de-problemas)
13. [Referências](#referências)

---

## 1. Conceitos essenciais (resumo)

**Container** = um pacote que reúne, numa única unidade, o *código + as dependências + as bibliotecas + as configurações do ambiente*. Esse pacote roda de forma **idêntica** em qualquer máquina que tenha o runtime — seu notebook, o cluster HPC ou o computador de um colega. Resolve o clássico *"…mas funciona na minha máquina"*.

**Container × Máquina Virtual.** A VM virtualiza o hardware inteiro e carrega um SO completo (pesada, boot lento). O container compartilha o kernel do host e empacota só o necessário (leve, sobe em segundos).

**Por que Apptainer/Singularity em ciência?**
- Roda **sem daemon e sem root** — por isso funciona em clusters HPC compartilhados, onde o Docker normalmente não entra.
- A imagem é **um único arquivo `.sif`**: fácil de mover, versionar, arquivar e citar em um artigo.
- Integra com SLURM, MPI e GPUs.
- Ainda assim, **roda imagens Docker** (via `docker://`), então você não perde o ecossistema.

**Reprodutibilidade e controle de ambiente.** O container dá quatro coisas: *ambiente empacotado* (nada de instalar na mão), *isolamento* (sem conflito de versões), *imutabilidade* (o `.sif` é somente-leitura e se comporta igual sempre) e *proveniência* (a receita `.def` documenta como o ambiente foi construído). **Mesmo ambiente → mesmos resultados**, hoje e daqui a anos.

**Vocabulário mínimo:**

| Termo | O que é |
|---|---|
| **`.def`** | A *receita*: um arquivo de texto com as instruções de como construir a imagem. |
| **`.sif`** | A *imagem* final: pacote imutável, executável e autocontido. É o que você roda e compartilha. |
| **build** | O processo que transforma `.def` em `.sif`. |
| **Bootstrap / base** | A imagem de origem de onde você parte (ex.: `docker://ubuntu:22.04`). |
| **bind mount** | Montar pastas do host dentro do container para ler/gravar os seus dados. |

---

## 2. Preparação do ambiente

O Apptainer roda em **Linux**. Em Windows use **WSL2** (Ubuntu); em macOS use uma VM leve (ex.: Lima) — instruções mais abaixo.

### 2.1 Linux (Ubuntu/Debian) ou Windows via WSL2

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:apptainer/ppa
sudo apt update
sudo apt install -y apptainer
```

> No **Windows**: abra o PowerShell como administrador, rode `wsl --install`, reinicie, abra o Ubuntu recém-instalado e então rode os comandos acima dentro dele.

### 2.2 Rocky Linux / RHEL / Fedora

```bash
sudo dnf install -y epel-release   # em Fedora, pule esta linha
sudo dnf install -y apptainer
```

### 2.3 macOS

O kernel do macOS não roda containers Linux nativamente. Use o **Lima** (via Homebrew) seguindo a documentação do Apptainer, ou uma VM Linux. Alternativamente, faça os exercícios em uma máquina Linux remota / cluster.

### 2.4 Teste de instalação ✅

```bash
apptainer --version
apptainer exec docker://alpine cat /etc/alpine-release
```

**Resultado esperado:** a versão do Apptainer aparece e, na segunda linha, um número de versão do Alpine Linux (ex.: `3.20.x`). Se isso funcionou, o Apptainer baixou uma imagem Docker, converteu para `.sif` e executou um comando dentro dela. Você já rodou seu primeiro container. 🎉

> **Dica — organize o cache.** O Apptainer guarda downloads em `~/.apptainer/cache`. Para controlar onde isso fica (útil em HPC, onde o `$HOME` tem cota):
> ```bash
> export APPTAINER_CACHEDIR=$HOME/.apptainer_cache
> mkdir -p "$APPTAINER_CACHEDIR"
> ```
> Coloque essa linha no seu `~/.bashrc` para torná-la permanente.

Crie também uma pasta de trabalho para a aula:

```bash
mkdir -p ~/curso-containers && cd ~/curso-containers
```

---

## Módulo 1 — Rodar containers prontos

🎯 **Objetivo:** entender a diferença entre `pull`, `run`, `exec` e `shell`, e rodar uma imagem já existente.

### 1.1 Baixar (pull) uma imagem para um arquivo `.sif`

```bash
apptainer pull docker://ubuntu:22.04
ls -lh ubuntu_22.04.sif
```

✅ **Esperado:** um arquivo `ubuntu_22.04.sif` de algumas dezenas de MB aparece na pasta. Essa é a sua imagem — portátil e imutável.

### 1.2 Os quatro modos de execução

```bash
# run  → executa o comando padrão da imagem (%runscript)
apptainer run ubuntu_22.04.sif echo "olá do container"

# exec → roda um comando arbitrário dentro da imagem
apptainer exec ubuntu_22.04.sif cat /etc/os-release

# shell → abre um shell interativo dentro do container
apptainer shell ubuntu_22.04.sif
#   (dentro dele, teste: cat /etc/os-release ; depois digite: exit)
```

✅ **Esperado:** `exec` mostra que o SO **dentro** do container é Ubuntu 22.04, mesmo que o seu host seja outra distribuição. Esse é o ponto central: o ambiente viaja junto com a imagem.

🧩 **Desafio:** rode `apptainer exec docker://python:3.12-slim python3 -c "print('python', __import__('sys').version)"` **sem** fazer `pull` antes. O que acontece? (O Apptainer baixa a imagem na hora e a executa.)

---

## Módulo 2 — Repositórios de imagens bioinformáticas

🎯 **Objetivo:** aprender a puxar ferramentas de bioinformática já empacotadas, de diferentes fontes. Você quase nunca precisa construir do zero — a comunidade já empacotou milhares de ferramentas.

### 2.1 Docker Hub (imagens com tags limpas)

Muitas organizações mantêm imagens com versionamento simples. Exemplo, a StaPH-B (saúde pública/genômica):

```bash
apptainer exec docker://staphb/samtools:1.21 samtools --version
```

✅ **Esperado:** a versão do `samtools` (1.21) impressa a partir de dentro do container, sem você ter instalado nada no host.

### 2.2 BioContainers via Quay.io

O projeto **BioContainers** empacota automaticamente cada pacote do Bioconda como uma imagem, hospedada em `quay.io/biocontainers`. O padrão do endereço é:

```
docker://quay.io/biocontainers/<ferramenta>:<versão>--<hash-de-build>
```

O `--<hash-de-build>` **muda** a cada rebuild, então você precisa copiar a *tag exata*. Para descobri-la:
1. Acesse `https://quay.io/repository/biocontainers/<ferramenta>?tab=tags` (ex.: `.../biocontainers/bcftools?tab=tags`).
2. Copie a tag mais recente da versão que você quer.

Exemplo (confirme a tag na página antes de rodar):

```bash
apptainer pull docker://quay.io/biocontainers/bcftools:1.21--h8b25389_0
apptainer exec bcftools_1.21--h8b25389_0.sif bcftools --version
```

### 2.3 Galaxy Project — depósito de imagens Singularity prontas

O Galaxy mantém um índice com os `.sif` **já convertidos** dos BioContainers, em `https://depot.galaxyproject.org/singularity/`. Isso evita a conversão local e é ótimo para HPC. Fluxo:
1. Abra a listagem `https://depot.galaxyproject.org/singularity/` no navegador (é uma lista enorme — use Ctrl+F).
2. Encontre o nome exato do arquivo, ex.: `samtools:1.21--h50ea8bc_0`.
3. Puxe direto pela URL:

```bash
apptainer pull https://depot.galaxyproject.org/singularity/samtools:1.21--h50ea8bc_0
```

✅ **Esperado:** um `.sif` baixado diretamente, sem etapa de conversão a partir de camadas Docker.

🧩 **Desafio:** obtenha o `fastqc` por **duas** fontes diferentes (Quay.io e Galaxy depot) e compare o tamanho dos `.sif` resultantes.

> **Quando usar qual?**
> - **Docker Hub** → ferramentas com tags simples e imagens de uso geral.
> - **BioContainers (Quay.io)** → praticamente qualquer pacote Bioconda, mas você lida com o hash de build.
> - **Galaxy depot** → o `.sif` pronto do BioContainers, sem conversão (bom para clusters).

---

## Módulo 3 — Seqera Containers

🎯 **Objetivo:** gerar um container sob demanda a partir de nomes de pacotes Conda/PyPI, usando a plataforma **[seqera.io/containers](https://seqera.io/containers/)** — sem escrever um `Dockerfile` nem um `.def`.

O Seqera Containers **não é um registro tradicional**: em vez de procurar imagens prontas, você monta um `environment.yml` visualmente (escolhendo pacotes) e a plataforma **constrói a imagem na hora** (por trás, usa o serviço Wave). Ela devolve uma URI de imagem Docker **ou** Singularity que você usa imediatamente. É gratuito e faz varredura de vulnerabilidades (Trivy) no processo.

### 3.1 Gerar uma imagem Singularity pela interface web

1. Acesse **https://seqera.io/containers/**.
2. Na busca, digite `samtools` e clique em **Add** no resultado `bioconda::samtools`.
3. (Opcional) adicione um segundo pacote, ex.: `bcftools` — os dois vão para a **mesma** imagem.
4. Em **Container settings**, escolha **Singularity** e **linux/amd64** (use `arm64` só se o seu processador for ARM, como Apple Silicon em VM ARM).
5. Clique em **Get Container**.
6. Copie a **URI da imagem**. Para Singularity ela terá o formato:
   ```
   oras://community.wave.seqera.io/library/samtools_bcftools:<identificador>
   ```

### 3.2 Puxar a imagem no seu computador

```bash
apptainer pull oras://community.wave.seqera.io/library/samtools:<cole-o-identificador-aqui>
```

✅ **Esperado:** o `.sif` é baixado do registro comunitário via protocolo **ORAS**. Rode `apptainer exec <arquivo>.sif samtools --version` para confirmar.

> **Nota técnica:** o `pull` via `oras://` exige uma versão de Apptainer/Singularity com suporte ao pseudo-protocolo ORAS (versões recentes têm). Se der erro, atualize o Apptainer (`sudo apt install --only-upgrade apptainer`).

### 3.3 Alternativa sem instalar nada

A interface também permite **baixar o `.sif` como arquivo** diretamente pelo navegador, sem precisar de Apptainer instalado para o download — útil para transferir depois a um cluster.

### 3.4 Multipacote a partir de um `environment.yml`

Se você já tem um `environment.yml` do Conda, pode **colar** os nomes dos pacotes direto na busca. Isso cria um único container com todo o seu ambiente.

🧩 **Desafio:** gere um container com `samtools` **+** `bcftools` **+** `bwa`, puxe-o e confirme que os três comandos existem dentro dele (`apptainer exec img.sif which samtools bcftools bwa`).

> ⚠️ **Reprodutibilidade.** Builds sob demanda são cômodos, mas para reprodutibilidade e proveniência a longo prazo, **fixe a URI exata** que você usou (ela identifica aquele build específico) e, idealmente, **arquive o `.sif`** (ou empurre-o para um registro seu). Não confie que "vou reconstruir depois" — reconstruções futuras podem trazer versões diferentes.

---

## Módulo 4 — Construir a sua própria imagem

🎯 **Objetivo:** escrever a sua primeira receita `.def` e transformá-la em um `.sif`.

### 4.1 O clássico "lolcow" (para entender a mecânica)

Crie um arquivo `lolcow.def`:

```singularity
BootStrap: docker
From: ubuntu:22.04

%post
    apt-get -y update
    apt-get -y install cowsay lolcat

%environment
    export LC_ALL=C
    export PATH=/usr/games:$PATH

%runscript
    date | cowsay | lolcat

%labels
    Author SeuNome
    Version 1.0
```

Construa a imagem:

```bash
apptainer build lolcow.sif lolcow.def
```

> **Precisa de root?** Em um **computador pessoal Linux** com *user namespaces* habilitados (padrão em distros modernas e no WSL2), o build costuma funcionar **sem `sudo`**. Se der erro de permissão, tente:
> ```bash
> apptainer build --fakeroot lolcow.sif lolcow.def
> ```
> Em uma máquina onde você **tem** `sudo`, `sudo apptainer build lolcow.sif lolcow.def` também funciona. Em **cluster HPC**, use `--fakeroot`.

Rode:

```bash
apptainer run lolcow.sif
```

✅ **Esperado:** uma vaca de ASCII colorida dizendo a data. Parabéns — você construiu e executou um container do zero.

### 4.2 Uma receita bioinformática de verdade

Crie `bio.def` (instala `samtools` + `bcftools`):

```singularity
BootStrap: docker
From: ubuntu:22.04

%labels
    Author    SeuNome
    Version   1.0
    Descricao Container com samtools + bcftools

%post
    apt-get -y update
    apt-get -y install --no-install-recommends samtools bcftools
    apt-get clean

%environment
    export LC_ALL=C

%runscript
    exec samtools "$@"

%help
    Container com samtools + bcftools.
    Uso: apptainer run bio.sif view arquivo.bam
```

```bash
apptainer build bio.sif bio.def          # adicione --fakeroot se necessário
apptainer exec bio.sif samtools --version
apptainer exec bio.sif bcftools --version
```

✅ **Esperado:** as versões das duas ferramentas, ambas vindas de dentro da **sua** imagem.

> **Boa prática:** para reprodutibilidade real, fixe versões (`samtools=1.21` via um gerenciador de pacotes que suporte isso, como o Conda) em vez de deixar o `apt` pegar "a mais recente". Veja o Módulo 5 e o desafio final.

---

## Módulo 5 — Configurar as seções do `.def`

🎯 **Objetivo:** entender e manipular cada seção da receita.

| Seção | Para que serve | Quando roda |
|---|---|---|
| `Bootstrap:` / `From:` | Define a imagem base de onde partir. | — |
| `%files` | Copia arquivos do host para dentro da imagem. | build |
| `%post` | Comandos de construção: instalar softwares, dependências. | build |
| `%environment` | Variáveis de ambiente da imagem. | execução |
| `%runscript` | O que roda ao chamar `apptainer run`. | execução |
| `%labels` | Metadados: autor, versão, descrição. | — |
| `%help` | Texto exibido por `apptainer run-help`. | — |

### 5.1 Exercícios de configuração

Partindo do seu `bio.def`:

1. **`%help` e metadados.** Rode `apptainer run-help bio.sif` e `apptainer inspect bio.sif`. Confira que o texto de `%help` e os `%labels` aparecem. Edite-os, reconstrua e verifique de novo.

2. **`%runscript` com argumentos.** O `%runscript` acima usa `exec samtools "$@"`, ou seja, tudo que você passar depois do nome da imagem vai para o `samtools`. Teste:
   ```bash
   apptainer run bio.sif --version
   apptainer run bio.sif view      # (vai reclamar por falta de arquivo — esperado)
   ```

3. **`%environment`.** Adicione uma variável, por exemplo `export MINHA_REF=/refs/genoma.fa`, reconstrua e confirme:
   ```bash
   apptainer exec bio.sif bash -c 'echo $MINHA_REF'
   ```

4. **`%files`.** Crie um arquivo `notas.txt` no host, adicione uma seção `%files` que o copie para dentro da imagem, reconstrua e verifique:
   ```singularity
   %files
       notas.txt /opt/notas.txt
   ```
   ```bash
   apptainer exec bio.sif cat /opt/notas.txt
   ```

🧩 **Desafio:** transforme o `%runscript` em um pequeno *pipeline* que recebe um BAM e imprime as estatísticas (`samtools flagstat "$1"`).

---

## Módulo 6 — Executar com os seus dados

🎯 **Objetivo:** por padrão, o container enxerga o seu `$HOME`, o `/tmp` e a pasta atual. Para acessar **outras** pastas, use `--bind` (montar pasta do host → caminho dentro do container).

### 6.1 Preparar um dado de teste (offline)

```bash
mkdir -p ~/curso-containers/dados
cd ~/curso-containers/dados
printf '>seq1\nACGTACGTACGTACGTACGT\n>seq2\nTTTTGGGGCCCCAAAA\n' > teste.fasta
cat teste.fasta
```

### 6.2 Rodar uma ferramenta sobre esse dado

```bash
# indexar o FASTA com samtools, usando a imagem que você construiu
apptainer exec bio.sif samtools faidx teste.fasta
ls -l teste.fasta.fai
cat teste.fasta.fai
```

✅ **Esperado:** um arquivo `teste.fasta.fai` (índice) criado **no host**, gerado por uma ferramenta que só existe **dentro** do container. Como você estava na pasta atual, o bind foi automático.

### 6.3 Montar uma pasta arbitrária com `--bind`

```bash
apptainer exec --bind /caminho/no/host:/mnt bio.sif samtools faidx /mnt/teste.fasta
```

Aqui `/caminho/no/host` (fora do `$HOME`) fica visível como `/mnt` dentro do container.

🧩 **Desafio:** monte uma pasta de referências em modo somente-leitura usando a sintaxe `--bind /refs:/refs:ro` e confirme que não é possível gravar nela de dentro do container.

---

## Módulo 7 — Ambientes Conda isolados dentro do container

🎯 **Objetivo:** empacotar um ambiente **Conda** (com versões fixas de várias ferramentas) **dentro** de uma imagem Singularity e executá-lo a partir do container.

**Por que juntar os dois?** São camadas complementares de reprodutibilidade:
- O **container** garante o sistema operacional, as bibliotecas de sistema e a portabilidade.
- O **Conda** instala centenas de ferramentas de bioinformática (canal **Bioconda**) com **versões exatas**, sem precisar compilar nada.

Combinados, você tem um único `.sif` autocontido cujo ambiente é descrito por um `environment.yml` legível e versionável — o auge da reprodutibilidade.

### 7.1 A lista de versões — `environment.yml`

Crie um arquivo `environment.yml`:

```yaml
name: bioenv
channels:
  - conda-forge
  - bioconda
dependencies:
  - samtools=1.21
  - bcftools=1.21
  - bwa=0.7.18
```

O campo `name:` define o nome do ambiente isolado (`bioenv`). As versões estão **fixadas** — é isso que torna o build reproduzível.

### 7.2 A receita — `conda.def`

Crie `conda.def` (instala o Miniforge, que já traz o `mamba`, e cria o ambiente a partir do `environment.yml`):

```singularity
Bootstrap: docker
From: ubuntu:22.04

%files
    environment.yml /opt/environment.yml

%post
    apt-get update && apt-get install -y --no-install-recommends wget bzip2 ca-certificates
    # instala o Miniforge (conda + mamba, canal conda-forge por padrão)
    wget -qO /tmp/miniforge.sh \
        https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
    bash /tmp/miniforge.sh -b -p /opt/conda
    rm /tmp/miniforge.sh
    # cria o ambiente isolado 'bioenv' a partir do environment.yml
    /opt/conda/bin/mamba env create -f /opt/environment.yml
    /opt/conda/bin/mamba clean --all --yes
    apt-get clean && rm -rf /var/lib/apt/lists/*

%environment
    # coloca o env 'bioenv' no PATH -> ele já vem ATIVO, sem 'conda activate'
    export PATH=/opt/conda/envs/bioenv/bin:$PATH
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8

%runscript
    exec "$@"

%labels
    Author    SeuNome
    Version   1.0
    Descricao Ambiente conda isolado (bioenv) dentro do container
```

Construa a imagem (o `environment.yml` precisa estar na mesma pasta):

```bash
apptainer build bioenv.sif conda.def        # adicione --fakeroot em cluster HPC
```

> ⏳ O primeiro build baixa o Miniforge e resolve o ambiente — pode levar alguns minutos. É normal.

### 7.3 O truque da "ativação": PATH em vez de `conda activate`

Dentro de um container não há shell interativo com os *hooks* do Conda carregados, então `conda activate` não funciona bem em scripts. A solução limpa é **colocar o diretório `bin` do ambiente no `PATH`**, feito na seção `%environment`. Assim o ambiente `bioenv` **já vem ativo** em toda execução — você chama a ferramenta diretamente.

### 7.4 Executar a partir do container

```bash
# as ferramentas do env já estão no PATH (via %environment):
apptainer exec bioenv.sif samtools --version
apptainer exec bioenv.sif bcftools --version
apptainer exec bioenv.sif bwa 2>&1 | head -3

# via %runscript (exec "$@"): tudo após o .sif vai para o shell do container
apptainer run bioenv.sif samtools --version
```

✅ **Resultado esperado:** as três ferramentas respondem com suas versões fixadas, todas vindas do ambiente Conda **isolado** dentro da imagem.

### 7.5 Confirmar que veio do ambiente isolado

```bash
apptainer exec bioenv.sif which samtools
# -> /opt/conda/envs/bioenv/bin/samtools   (do env 'bioenv', não do sistema)
```

### 7.6 E se eu tiver mais de um ambiente?

Se a sua imagem tiver **vários** ambientes, não faz sentido colocar todos no `PATH`. Nesse caso, deixe o `%environment` neutro e selecione o ambiente na hora de executar com `conda run -n`, que cuida da ativação completa (inclusive scripts de ativação):

```bash
apptainer exec bioenv.sif /opt/conda/bin/conda run -n outro_env comando --opcoes
```

### 7.7 Alternativa mais enxuta — base `micromamba`

Para imagens menores, parta da imagem oficial `mambaorg/micromamba` (que já traz o gerenciador instalado em `/opt/conda`):

```singularity
Bootstrap: docker
From: mambaorg/micromamba:1.5.8

%files
    environment.yml /tmp/environment.yml

%post
    micromamba install -y -n base -f /tmp/environment.yml
    micromamba clean --all --yes

%environment
    export PATH=/opt/conda/bin:$PATH

%runscript
    exec "$@"
```

> 💡 **Atalho:** se você não quiser manter o `.def`, o **Seqera Containers** (Módulo 3) faz exatamente isto por você — recebe um `environment.yml` e devolve a imagem pronta (Docker ou Singularity), já com varredura de segurança.

🧩 **Desafio:** adicione ao `environment.yml` uma versão específica de Python e um pacote instalado via `pip` (dica: use a chave `pip:` dentro de `dependencies:`), reconstrua e confirme com `apptainer exec bioenv.sif python --version`.

---

## Desafio final

Monte um pequeno projeto reprodutível e versionável:

1. Escreva um `analise.def` que instale, **com versões fixas**, as ferramentas que você usa (dica: parta de uma base `mambaorg/micromamba` ou use o Seqera Containers para gerar a imagem a partir de um `environment.yml` com versões travadas).
2. Escreva um `%runscript` que execute uma etapa da sua análise real (ex.: `fastqc`, alinhamento, `samtools sort`).
3. Construa o `.sif`, rode sobre um dado de teste e confira o resultado.
4. Crie um repositório Git contendo **o `.def`, o `environment.yml` e um `README`** — **mas não** o `.sif` (é grande; a receita reconstrói tudo).
5. Escreva no `README` a URI exata do Seqera Containers ou a tag exata da imagem base que você usou, para que qualquer pessoa reproduza o ambiente.

Se você conseguiu fazer isso, alcançou o **Nível 3** de reprodutibilidade da aula: container + receita versionada + proveniência registrada.

---

## Checklist de aprendizagem

Marque conforme avança:

- [ ] Instalei o Apptainer e rodei o container de teste (`alpine`).
- [ ] Entendi a diferença entre `pull`, `run`, `exec` e `shell`.
- [ ] Puxei uma ferramenta de bioinformática do Docker Hub.
- [ ] Puxei uma imagem do BioContainers (Quay.io) usando a tag correta.
- [ ] Puxei um `.sif` pronto do depósito do Galaxy.
- [ ] Gerei um container pela plataforma Seqera Containers e o puxei via `oras://`.
- [ ] Escrevi um `.def`, construí o `.sif` e o executei.
- [ ] Configurei `%post`, `%environment`, `%runscript`, `%labels`, `%help` e `%files`.
- [ ] Rodei uma ferramenta sobre os meus próprios dados usando `--bind`.
- [ ] Construí um container com um ambiente Conda isolado (`environment.yml`) e executei suas ferramentas.
- [ ] Concluí o desafio final com um projeto versionado no Git.

---

## Solução de problemas

| Sintoma | Causa provável / solução |
|---|---|
| `FATAL: ... could not use fakeroot` no build | *User namespaces* desabilitados. Tente sem `--fakeroot`, ou com `sudo`, ou peça ao admin do cluster. |
| `pull` do `oras://` falha | Versão antiga sem suporte a ORAS. `sudo apt install --only-upgrade apptainer`. |
| `toomanyrequests` ao puxar do Docker Hub | Limite de requisições anônimas do Docker Hub. Espere um pouco, ou use BioContainers/Galaxy depot. |
| Sem espaço em disco durante o build/pull | Aponte o cache para um disco maior: `export APPTAINER_CACHEDIR=/caminho/grande`. |
| Ferramenta "não encontra" um arquivo que existe | O caminho está fora do que o container enxerga. Use `--bind pasta_do_host:/mnt`. |
| Tag do BioContainers "não existe" | O hash de build mudou. Copie a tag atual da aba *Tags* no Quay.io ou do depósito do Galaxy. |
| macOS não roda `apptainer` | O kernel não é Linux. Use Lima/VM, ou faça os exercícios em uma máquina Linux. |

---

## Referências

- Apptainer — Instalação: https://apptainer.org/docs/admin/main/installation.html
- Apptainer — Guia do usuário / Quick Start: https://apptainer.org/docs/user/main/quick_start.html
- BioContainers (registro): https://quay.io/organization/biocontainers
- Galaxy Project — depósito de imagens Singularity: https://depot.galaxyproject.org/singularity/
- Seqera Containers: https://seqera.io/containers/
- Seqera / Wave (documentação): https://docs.seqera.io/wave

---

*Bons builds! Qualquer imagem que você construir hoje vai rodar igual no seu notebook, no cluster e no computador de quem for reproduzir a sua análise.*
