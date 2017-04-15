# Tareas pendientes

1. La puntuación no está terminada ya que permite que un usuario puntue más de una vez al mismo post. Para evitarlo habría que añadir una entidad a la base de datos y permitir solo la modificación del rating. No lo hago por falta de tiempo.
2. También falta la paginación. No me la he planteado ya que no es más que limitar las querys y eso ya lo he probado con la diferencia entre posts públicos y privados
3. Como detalle me faltan los spinner en las comunicaciones (tarda algo en cargar, al menos aquí en Cádiz)
4. Cada vez que refresca los post tiene que recargar la imagen asociada. Eso no mola. Buscar solución

## Dudas

1. Tengo la sensación de que el realtimeupdate consume mucho ancho de banda. Por ejemplo, al volver de mis posts a los posts públicos pierdo la referencia del listener de mis posts y si vuelvo a cargar mis posts creo otro listener
	- No tengo claro si eso me deja dos listeners. Si fuera así tendría que controlar la navegación hacia atrás (hacia delante - detalle de mi post o nuevo post - , me interesa mantener el listener). Si no fuera así, me interesaría mantenerlo para no recargar. La única manera que se me ocurre es gestionarlo yo desde el CloudManager (un dictionario de pantallas y listeners podría funcionar), pero se empieza a complicar.
	- **Conclusión**: Lo voy a dejar como está, consumiendo mucho porque es una práctica, pero no se si me convence FireBase para la vida real.
