# MANUAL - mri_Qdraw

## O que o recurso faz (descrição funcional)
Sistema de posicionamento de imagens no espaço 3D do mundo do GTA V usando 4 vértices. Permite colocar imagens de URLs ou texturas locais, com renderização via nativas do jogo (sem NUI), persistência em data.json e ferramentas para desenvolvedores.

## Funcionalidades principais
- **Sistema de 4 vértices**: Posicionamento preciso usando 4 pontos de canto.
- **Espaço 3D**: Imagens renderizadas no mundo, mantendo perspectiva correta.
- **Suporte a URL e imagens locais**: Carrega de qualquer URL ou texturas streamed.
- **Raycast picker**: Clique para posicionar vértices no mundo.
- **Modo desenvolvedor**: Mostra marcadores, detecta imagens próximas, permite remoção rápida.
- **Persistência**: Armazenamento em data.json, imagens persistem após reinício.

## Como funciona (fluxo de trabalho)

### Colocação de imagem
1. Jogador usa comando `/draw` ou `rw_draw++` para alternar modo de desenho.
2. Sistema usa raycast: jogador mira no mundo, clica para posicionar cada um dos 4 vértices.
3. Após posicionar os 4 vértices, imagem é renderizada no espaço 3D.

### Modo desenvolvedor (admin)
1. Admin usa `/dev` para alternar modo desenvolvedor.
2. Marcadores aparecem para imagens posicionadas, mostrando IDs.
3. Admin pode remover imagens via `/rem <id>` ou adicionar via `/img <id> <url>`.

## Opções de configuração disponíveis
Configurações em config/config.lua:

| Opção | Padrão | Descrição |
|-------|--------|-----------|
| Config.MaxImages | 50 | Máximo de imagens por servidor. |
| Config.MaxImagesPerPlayer | 5 | Limite por jogador. |
| Config.DevMode | true | Ativa recursos para desenvolvedores. |
| Config.DevMarkerColor | {255, 0, 0, 100} | RGBA dos marcadores. |
| Config.DefaultWidth | 1.0 | Largura padrão. |
| Config.DefaultHeight | 1.0 | Altura padrão. |
| Config.MaxDistance | 100.0 | Distância máxima de renderização. |
| Config.AdminGroups | {'admin', 'god'} | Grupos com permissão. |

## Comandos disponíveis
| Comando | Permissão | Descrição |
|---------|------------|-------------|
| `rw_draw++` | Todos | Alterna modo de desenho (alias). |
| `draw` | Todos | Alterna modo de desenho (alias). |
| `/dev` | Admin | Alterna modo desenvolvedor com marcadores. |
| `/rem <id>` | Admin | Remove imagem por ID. |
| `/img <id> <url>` | Admin | Adiciona nova imagem com URL. |

## Eventos que dispara/ouve

### Cliente → Servidor
| Evento | Parâmetros | Descrição |
|--------|------------|-----------|
| mri_Qdraw:client:toggleDraw | none | Alterna modo de desenho. |
| mri_Qdraw:client:addImage | id, url, vertices | Adiciona nova imagem. |
| mri_Qdraw:client:removeImage | id | Remove imagem por ID. |
| mri_Qdraw:client:updateVertex | id, vertexIndex, coords | Atualiza posição do vértice. |
| mri_Qdraw:client:toggleDevMode | none | Alterna modo desenvolvedor. |

### Servidor → Cliente
| Evento | Parâmetros | Descrição |
|--------|------------|-----------|
| mri_Qdraw:server:requestImages | none | Solicita todas as imagens do servidor. |
| mri_Qdraw:server:saveImage | imageData | Salva imagem no data.json. |
| mri_Qdraw:server:deleteImage | id | Deleta imagem do data.json. |
| mri_Qdraw:server:syncImages | none | Sincroniza imagens com todos os clients. |

## Exports que fornece/consome

### Exports do cliente
| Export | Parâmetros | Descrição |
|--------|------------|-----------|
| toggleDraw | none | Alterna modo de desenho. |
| addImage | id, url, vertices | Adiciona imagem com 4 vértices. |
| removeImage | id | Remove imagem. |
| getImages | none | Obtém todas as imagens. |
| toggleDevMode | none | Alterna modo desenvolvedor. |

### Exports do servidor
| Export | Parâmetros | Descrição |
|--------|------------|-----------|
| getAllImages | none | Obtém todas as imagens. |
| saveImage | imageData | Salva imagem. |
| deleteImage | id | Deleta imagem. |
| syncImages | none | Sincroniza com clients. |

### Exports consumidos
Nenhum export externo consumido, usa ox_lib para UI e notificações.

## Integração com outros recursos MRI Qbox
- **ox_lib**: Componentes UI, notificações e raycast.
- Outros recursos podem usar exports para adicionar imagens dinamicamente no mundo.

## Casos de uso / exemplos práticos
1. **Sinalização de rua**: Admin coloca imagem de placa de rua usando `/img 1 url_da_placa`.
2. **Propaganda em quadra**: Desenvolvedor usa modo de desenho para colocar banner publicitário em quadra de basquete.
3. **Mapa personalizado**: Coloca imagem de mapa do servidor em parede de prédo.
4. **Aviso de zona**: Imagem de "Área Restrita" posicionada em entrada de base policial.

## Dicas de solução de problemas
- **Imagem não aparece**: Verifique se a URL é acessível ou se a textura local está streamed.
- **Modo de desenho não ativa**: Confira se o recurso está funcionando e não há conflitos de keybind.
- **Performance baixa**: Reduza Config.MaxImages e Config.MaxDistance.
- **data.json corrompido**: Verifique sintaxe JSON, faça backup regular.
- **Modo dev não mostra marcadores**: Confirme que Config.DevMode está true e jogador é admin.
