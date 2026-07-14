# mri_Qdraw — Manual

Posiciona imagens de URL no mundo 3D como pôsteres, definidos por quatro vértices marcados em jogo e renderizados via DUI, sem NUI.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Permissões (ACE)](#permissões-ace)
4. [Configuração](#configuração)
5. [Comandos](#comandos)
6. [Criar um pôster](#criar-um-pôster)
7. [Modo desenvolvedor](#modo-desenvolvedor)
8. [Persistência e sincronização](#persistência-e-sincronização)
9. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
10. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `ox_lib` | Sim | `lib.addCommand` e `lib.inputDialog` |

Não depende de framework nem de banco de dados: os pôsteres ficam em `data.json`, dentro do próprio recurso.

---

## Instalação

1. Copie a pasta `mri_Qdraw` para `resources/`.
2. Adicione ao `server.cfg`:
   ```
   ensure mri_Qdraw
   ```
3. Garanta que o servidor tem permissão de escrita na pasta do recurso — o `data.json` é reescrito a cada criação, troca de imagem ou remoção (`SaveResourceFile`).
4. Libere a ACE de admin (veja abaixo).

Não há conflito conhecido com outros recursos.

---

## Permissões (ACE)

Os quatro comandos são registrados com `lib.addCommand(..., restricted = 'group.admin')`, o que gera uma ACE `command.<nome>` para cada um:

```
add_ace group.admin command.rw_draw++/draw allow
add_ace group.admin command.rw_draw++/dev allow
add_ace group.admin command.rw_draw++/img allow
add_ace group.admin command.rw_draw++/rem allow
```

Além disso, o servidor revalida quem criou ou trocou a imagem de um pôster com `IsPlayerAceAllowed(source, "command")` — sem essa ACE, o evento é descartado mesmo que o comando tenha passado.

```
add_ace group.admin command allow
```

---

## Configuração

Arquivo: `configuration.lua`.

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `DATA.Render_Distance` | number | Sim | Distância em metros a partir da qual o pôster deixa de ser desenhado. Medida do vértice superior esquerdo até o jogador |
| `DATA.Edit_Distance` | number | Sim | Raio de busca do pôster mais próximo no modo desenvolvedor |
| `DATA.Debug` | bool | Sim | Presente no config, mas os prints de diagnóstico (`Clmsg`) testam a global `debug` do Lua, não este campo |

---

## Comandos

| Comando | Permissão | Descrição |
|---|---|---|
| `rw_draw++/draw` | ACE `command.rw_draw++/draw` | Inicia a marcação dos quatro vértices e cria o pôster |
| `rw_draw++/dev` | ACE `command.rw_draw++/dev` | Liga/desliga o modo desenvolvedor |
| `rw_draw++/img <uid> <url>` | ACE `command.rw_draw++/img` | Troca a imagem de um pôster existente. Os valores são pedidos em um diálogo |
| `rw_draw++/rem <target>` | ACE `command.rw_draw++/rem` | Remove o pôster de UID `<target>` |

---

## Criar um pôster

1. Execute `rw_draw++/draw`.
2. Mire com a câmera e marque, nesta ordem: **[1] superior esquerdo**, **[2] superior direito**, **[3] inferior esquerdo**, **[4] inferior direito**. Cada ponto é confirmado com `E` (a posição do raycast aparece na tela).
3. `DEL` a qualquer momento cancela a criação.
4. Preencha o diálogo com **Height**, **Width** (resolução do DUI, não o tamanho no mundo — a área é definida pelos vértices) e a **Url** da imagem.
5. O pôster recebe um UID sequencial e é salvo.

A imagem é carregada em um DUI e desenhada como dois `DrawSpritePoly` formando o quadrilátero, então qualquer URL que o CEF consiga renderizar funciona.

---

## Modo desenvolvedor

`rw_draw++/dev` liga um loop que localiza o pôster mais próximo dentro de `DATA.Edit_Distance` e:

- desenha um marcador em cada um dos quatro vértices;
- mostra na tela o UID do pôster e os comandos prontos para remover (`rw_draw++/rem <uid>`) e trocar a imagem (`rw_draw++/img <uid>`).

Execute o comando de novo para desligar.

---

## Persistência e sincronização

Os pôsteres ficam em `data.json`, na raiz do recurso. Ao entrar no servidor, o client dispara `rw_draw++:GetData` e recebe a lista completa.

**Limitação conhecida:** criar, remover ou trocar a imagem de um pôster só é transmitido para o jogador que executou o comando (`TriggerClientEvent(..., source, ...)`). Os demais jogadores só veem a alteração ao reconectar ou depois de um restart do recurso — o `data.json` já está correto nesse meio-tempo.

---

## Entrypoints para outros recursos

O recurso não expõe exports. Os eventos de servidor abaixo são a única superfície utilizável, e ambos exigem a ACE `command` do jogador que os dispara.

```lua
-- Cria um pôster. O UID é atribuído pelo servidor.
TriggerServerEvent('rw_draw++:new', {
    Data = {
        Url    = 'https://exemplo.com/imagem.jpg',
        Height = 1080,
        Width  = 1920
    },
    Vertices = {
        [1] = topLeft,      -- vector3
        [2] = topRight,
        [3] = bottomLeft,
        [4] = bottomRight
    }
})

-- Troca a imagem de um pôster existente.
TriggerServerEvent('rw_draw++:img', uid, url)

-- Pede a lista completa de pôsteres; responde com rw_draw++:cl:init.
TriggerServerEvent('rw_draw++:GetData')
```

---

## Estrutura de arquivos

```
mri_Qdraw/
├── configuration.lua     — tabela DATA (distâncias e debug)
├── data.json             — pôsteres persistidos (fonte da verdade)
├── backend/
│   ├── main.lua          — lista em memória, UIDs, criação/remoção/troca de imagem, gate de ACE
│   ├── cmd.lua           — comandos rw_draw++/draw, /dev, /img, /rem
│   └── save.lua          — leitura e escrita do data.json
├── frontend/
│   ├── main.lua          — raycast, marcação dos vértices, diálogos, modo desenvolvedor
│   └── map.lua           — DUI, runtime txd e render dos pôsteres (DrawSpritePoly)
└── fxmanifest.lua
```
