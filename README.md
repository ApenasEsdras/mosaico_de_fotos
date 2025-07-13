# mosaico_de_fotos

### Funcionalidades Requeridas
✅ 1. Captura de Fotos – Botão "Tirar Foto" abre a câmera e retorna a imagem ao app.

✅ 2. Montagem de Mosaico – Cada foto é adicionada automaticamente ao mosaico com image_collage_widget, respeitando a orientação (vertical/horizontal).

✅ 3. Salvar em PDF – Botão "Salvar em PDF" tira screenshot com screenshot, gera PDF com pdf e salva localmente.

### Requisitos Funcionais
✅ Tela Principal com mosaico atualizado em tempo real.

✅ Botões Fixos: "Tirar Foto" e "Salvar em PDF" visíveis na parte inferior.

✅ Fluxo de Captura adiciona fotos ao mosaico automaticamente.

✅ Mosaico Dinâmico adapta o layout conforme a orientação da imagem.

✅ Geração de PDF salva o arquivo localmente, solicitando permissão se necessário.

### Requisitos Não Funcionais
❌ Plataforma FlutterFlow com uso de Custom Code para pacotes externos. (Implementado em Flutter nativo)

✅ Validação: botão "Salvar em PDF" é desabilitado se não houver fotos.

✅ Feedback ao Usuário com carregamento e mensagens de sucesso ou erro.

✅ Persistência: apenas o PDF é salvo, imagens ficam apenas em memória.