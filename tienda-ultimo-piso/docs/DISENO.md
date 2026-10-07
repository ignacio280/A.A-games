# Tienda del Último Piso — Documento de diseño

## Concepto en una línea
Llevas la única tienda en la cima de una mazmorra: compras barato el botín de los aventureros que suben heridos y decides a quién armar antes de que vuelvan a bajar. Si armas bien a los correctos, alguien llegará al piso 10 y derrotará al Señor de la Mazmorra.

## Fantasía y gancho
- No eres el héroe: eres quien decide qué héroe vive.
- Cada venta es una apuesta: un buen arma en manos de la persona equivocada se pierde con su cadáver.
- Los aventureros son personajes recurrentes que suben de nivel, recuerdan cómo los trataste y mueren de verdad.

## Loop de un día
1. **Mañana: llegan los heridos.** Los aventureros que sobrevivieron suben con botín. Cada uno ofrece sus objetos y pide un precio. Puedes regatear: cuanto más herido viene, menos le importa el precio. Si lo presionas demasiado se va (paciencia) y pierde confianza.
2. **Tarde: preparan la bajada.** Cada aventurero vivo, ya descansado, busca algo concreto (arma, armadura, amuleto, poción) y tiene un presupuesto. Para cada uno decides:
   - **Vender** a tu precio (acepta según el valor del objeto y su confianza en ti).
   - **Prestar** gratis: si vuelve, te devuelve el objeto y te da el 30% del oro que encontró; si muere, lo pierdes.
   - **Nada**, y guardar el objeto para alguien que lo aproveche mejor.
3. **Noche: la expedición.** Todos bajan. Piso a piso pelean (ataque contra peligro, defensa contra daño), recogen botín y oro, suben de nivel y se retiran al quedar heridos. Pueden morir. Lo que traigan será lo que te vendan mañana.
4. **Informe.** Quién volvió, hasta dónde llegó, quién murió. Tu reputación sube con los que vuelven usando tu equipo y baja con los que mueren con él. Más reputación trae más y mejores aventureros.

## Presión y objetivo
- **Renta** al Gremio cada 5 días, cada vez más cara (60, 120, 200, 300, 420, 560). Si no la pagas, pierdes la tienda.
- **Victoria:** un aventurero derrota al Señor de la Mazmorra en el piso 10.
- **Derrota:** no pagas la renta o pasan 30 días sin victoria.

La tensión central: el oro te mantiene vivo, pero solo armando bien a los aventureros llegas a la meta. Venderle lo mejor al que más paga no siempre es venderle al que más lejos llegará.

## Clases de aventureros
| Clase | Fuerte en | Se retira | Busca |
|---|---|---|---|
| Guerrero | ataque y defensa | tarde (30% vida) | armas |
| Pícaro | suerte (más botín) | pronto (50% vida) | amuletos |
| Mago | ataque alto | 40% vida | armas |
| Clérigo | defensa | 35% vida | armaduras |

## Objetos
Armas (ataque), armaduras (defensa), amuletos (suerte: más botín y oro), pociones (revive una vez al caer). Cinco niveles de calidad, de "de madera" a "del abismo". El nivel del botín depende de la profundidad.

## Alcance mínimo para Steam (versión 1.0)
Lo que ya cubre el prototipo está marcado.
- [x] Loop completo de día: compra, venta/préstamo, expedición, informe.
- [x] Aventureros persistentes con nivel, confianza, muerte y reclutamiento por reputación.
- [x] Renta, victoria y derrota.
- [ ] Arte 2D: interior de la tienda, retratos de aventureros, iconos de objetos.
- [ ] Sonido y música (campanilla de la puerta, monedas, ambiente).
- [ ] Rasgos de personalidad (avaricioso, leal, temerario) que cambian el regateo y la retirada.
- [ ] Eventos: mercader ambulante, inspector del Gremio, monstruo que sube a la tienda.
- [ ] Mejoras de la tienda entre rentas (vitrina, herrero que repara, alquimista).
- [ ] 3 a 4 mazmorras con jefes distintos para rejugabilidad.
- [ ] Guardado, ajustes, tutorial corto, localización ES/EN.
- [ ] Integración con Steamworks (logros) y build para Windows y Linux.

## Fuera de alcance
Combate controlado por el jugador, mundo abierto, multijugador.

## Plan
1. Prototipo jugable de la mecánica central (este repositorio).
2. Pruebas de juego y balance: precios, peligro por piso, renta.
3. Arte, sonido y contenido del alcance mínimo.
4. Página de Steam, capturas, tráiler y build con Steamworks.
