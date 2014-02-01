
Después de mucho pensar, he decidido modelar el problema como el problema de la Mochila, donde tenemos una serie de recursos con un peso y un valor asociado y debemos combinar los recuersos de forma que no se supere un determinado peso total y maximicemos la suma de sus valores.

En primer lugar proceso todas las palabras del diccionario para determinar la puntuación máxima que tienen en el tablero.

Después, agrupo las puntuaciones por la longitud de la palabra (+1 para pulsar el botón) y compruebo todas las combinaciones posibles de cantidades de palabras y sus longitudes para encontrar la solución a:

  Max(Punt(A*Ai + B*Bj + C*Ck))

Donde A, B, C son las longitudes de las palabras y para todo Xn, n <= número de palabras en el tablero de longitud X.