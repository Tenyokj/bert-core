// SPDX-License-Identifier: GPL-3.0
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@#▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇##########################▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@@#▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇#######%********************%#####@#▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▁@###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@####%%******%#################%******%####@▇▇▇▇▇▇▇▇▇▇▇@####▓▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▓######▇▇▇▇▇▇▇▇▇█#####*****##############################*****%####▇▇▇▇▇▇@######▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@##%####@▇▇▇▇#####****######################################****#####▇#####%##@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@##**%###▇@###%***############################################***%######**##@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###***#####***%########################*#######################%*%###***###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###%****%#############################%**##########################%****##@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###%*****%#######################%##*%**%##%#####################*****###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇####*******%###############%%****##%%%***%##****%##############******%#####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇█######********##%######%*********##%%%%****%#%********%#####%##*******###%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###*###%*******%#%***###%********##*%%%%*****%#%*******###%**##*******###***###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###**%###%*******##*****###******##%*%%%%%*****%#%****%##****%#%*******####***####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###**%#####%*******##%**###******##%*%%%%%*******##%*****##%**##*******######%**####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇####**%########*******##%##%******##%*%%%######%****##%*****#####******%########%**###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###**%###########%*****###******%##%*##############%*###*****%##*****%###########%**###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###***#####@#########****%##%****########################%***###****%##############***@##▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###**######**%%##%*%###%***###****%##%%%###########%*%##****##%**%###%**###%**%#####**%##@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###**%########%***%#%**%###%*%##%***%###%***%###%***%###***%##*%###%***%%****%#######%**###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###%**%###########%*********%######****####%********###%***######%*********%###########**%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###%**###############%*********%####%***#####*****####%**%####%*********%##############%**###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇##@**%##########**%######%********%###***%#####*#####***%##%********%#####%**###########**%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###**%#########*****#########%************%#########***%*********%########****##########**%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###**#########%****#########%###%***********#######**********%###%########%***%#########**%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇####**#########*****@##%#####****%###%********####%*******%###%****%########****%########***###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇####**########******###*#####%*******####%*****%#******%####*******%###%%##%*****########***###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇####**%######%*******##*%######****%#########%*****%#########%***%#####*###*******#######**%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇##@***######********###**######################%####################%**##%*******#######**%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇###%**#######********%##**%##############%%%%%###%**%#############%***##********#######%**%###▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@##%**%#######*********###%********%####%%%%%%%******%####%%*******%##%*******%########%**####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###***@########%*********%%######%%**###%%%%%%*****%###%*%%######%*********%##########***###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###**%#####*####%*****************###%##%%%%%*****######%***************%####*%#####%**####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###***####%**%######%**********%##%***###%%%%****###%***###*********%######%***#####***###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▓####***####****##########@######*******###%%%***%###******%#####@#########%***%####***@###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇####***####****%###%##########%********###%%%*%###********#########%%###****%###@***%###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###%***######%**##%%%%%########%*******##%%**###******%########%%%%##%*%#@#####***%###@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@###%***############%%%%%%#######%*****%##%%###*****%######%%%%%%########%####***%####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇#####***####******%#####%%%%%######****%#####****%#####%%%%%#####%******####***%####@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@####***%###%******%####%%%%%%%#####%**%###%**######%%%%%#####*******####%***#####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@####%***####%*******####%%%%%##%%####%##%%###%*##%%%%%####*******%####***%#####▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@####****####%*******####%%%%##%%%%######%***%##%%%###%*******%####****#####@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@####%****#####******#%####%##%%%%%%%%******##%%#####%*****#####****%####@@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@####%****######***##**######%%%%%%******%#####%*%#***%#####****%#####@#▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇######*****########****######%%%%*****#####%***##%#####%****%######@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇#######%*****######*****######%%***%####%****######%****%#######@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@#####@%*****%####%****#####%*%#####****%###%******########@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇#@#######%****####%****#########****####*****%#########▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇##########%*######***%#####***%#####%%#@########@█▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@##############@%**%#***%################@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇@@@############***#############@#@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇#@@###############@▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
// ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇    
/**
 *     NOTICE
 *
 *     BERT is an upgradeable DAO voting and grant protocol developed to turn
 *     community ideas into funded on-chain outcomes. The protocol enables users
 *     to submit ideas, participate in structured voting rounds with stake, and
 *     receive transparent grant distribution through upgradeable smart contracts
 *     on EVM-compatible blockchains.
 *
 *     Copyright (C) 2026, BERT contributors.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program. If not, see <https://www.gnu.org/licenses/>.
 */
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IGrantManager } from "../interfaces/IGrantManager.sol";
import { IFundingPool } from "../interfaces/IFundingPool.sol";
import { IIdeaRegistry } from "../interfaces/IIdeaRegistry.sol";
import { IVotingSystem } from "../interfaces/IVotingSystem.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import "../utils/IdeaStatus.sol";
import "../utils/Errors.sol";

/**
 * @title GrantManager
 * @notice Central coordinator for grant rounds, voting, and fund distribution
 * @dev Orchestrates the complete DAO grant lifecycle from creation to funding
 * @dev Pausable, Upgradeable
 * 
 * @custom:version 1.1.0
 */
contract GrantManagerUpgradeable is 
    Initializable, 
    ReentrancyGuardUpgradeable, 
    PausableUpgradeable, 
    RolesAwareUpgradeable, 
    IGrantManager 
{
    /* ========== CONTRACTS ========== */

    /// @notice VotingSystem contract interface
    IVotingSystem public votingSystem;
    
    /// @notice FundingPool contract interface
    IFundingPool public fundingPool;
    
    /// @notice IdeaRegistry contract interface
    IIdeaRegistry public ideaRegistry;

    /* ========== STATE VARIABLES ========== */
    
    /** @notice The author's share of their grant in basis points 
     *@dev Default is 95% 
     */
    uint256 public authorSharePercent; // 95%

    /* ========== PAYOUT CONSTANTS ========== */

    /// @notice First tranche released immediately after the winning author claims the grant
    /// @dev Expressed as a percentage of the author's reserved share
    uint256 public constant INITIAL_PAYOUT_PERCENT = 30;

    /// @notice Second tranche released after the in-process milestone is approved
    /// @dev Expressed as a percentage of the author's reserved share
    uint256 public constant IN_PROCESS_PAYOUT_PERCENT = 40;

    /// @notice Minimum waiting period before a rejected milestone can be submitted again
    /// @dev Applies independently per round and per milestone stage
    uint256 public constant MILESTONE_RESUBMIT_COOLDOWN = 48 hours;

    /* ========== MILESTONE CONSTANTS ========== */

    /// @notice Milestone identifier for the "project is in active implementation" proof stage
    uint8 public constant IN_PROCESS_STAGE = 1;

    /// @notice Milestone identifier for the "project is fully delivered" proof stage
    uint8 public constant COMPLETION_STAGE = 2;

    /// @notice Minimum number of approvals required to unlock the 40% in-process payout
    uint8 public constant IN_PROCESS_APPROVAL_THRESHOLD = 3;

    /// @notice Maximum number of reviewer votes collected for the in-process stage
    uint8 public constant IN_PROCESS_MAX_REVIEWERS = 5;

    /// @notice Minimum number of approvals required to unlock the final 30% payout
    uint8 public constant COMPLETION_APPROVAL_THRESHOLD = 2;

    /// @notice Maximum number of reviewer votes collected for the completion stage
    uint8 public constant COMPLETION_MAX_REVIEWERS = 3;

    /* ========== STRUCTS ========== */

    /**
     * @notice Tracks the staged payout state for a funded round
     * @dev Flow:
     *      1. `totalGrant` is set when the author claims the winning round
     *      2. `released` increases after every successful payout tranche
     *      3. boolean flags prevent the same tranche from being paid twice
     * @param ideaId Winning idea for the round
     * @param author Author entitled to receive the grant tranches
     * @param totalGrant Total author-side grant reserved after protocol share is carved out
     * @param released Cumulative amount already transferred to the author
     * @param initialClaimed True once the initial 30% payout has been executed
     * @param inProcessPaid True once the 40% in-process milestone payout has been executed
     * @param completionPaid True once the final 30% completion payout has been executed
     */
    struct GrantPayout {
        uint256 ideaId;
        address author;
        uint256 totalGrant;
        uint256 released;
        bool initialClaimed;
        bool inProcessPaid;
        bool completionPaid;
    }

    /**
     * @notice Stores the currently active or most recently settled milestone request for a stage
     * @dev Flow:
     *      1. the author submits a request with proof metadata
     *      2. reviewers cast approvals or rejections until the request resolves
     *      3. the request becomes inactive after approval or rejection
     *      4. `lastRejectedAt` gates resubmission via cooldown enforcement
     * @param requestId Monotonic identifier for submissions on the same round/stage
     * @param metadataURI Off-chain pointer with rich proof payloads
     * @param details Human-readable summary shown to reviewers and indexers
     * @param submittedAt Timestamp when the current request version was created
     * @param lastRejectedAt Timestamp of the latest rejected request for cooldown tracking
     * @param approvals Number of reviewer approvals collected for the active request
     * @param rejections Number of reviewer rejections collected for the active request
     * @param maxReviewers Maximum number of reviewer votes allowed for the stage
     * @param approvalThreshold Number of approvals needed for acceptance
     * @param active Whether this request can still receive votes
     */
    struct MilestoneRequest {
        uint256 requestId;
        string metadataURI;
        string details;
        uint256 submittedAt;
        uint256 lastRejectedAt;
        uint8 approvals;
        uint8 rejections;
        uint8 maxReviewers;
        uint8 approvalThreshold;
        bool active;
    }

    /* ========== STORAGE ========== */

    /// @notice Round-level payout state keyed by voting round ID
    /// @dev roundId => staged payout state
    mapping(uint256 => GrantPayout) private _grantPayouts;

    /// @notice Latest milestone request state for each round and payout stage
    /// @dev roundId => stage => request data
    mapping(uint256 => mapping(uint8 => MilestoneRequest)) private _milestoneRequests;

    /// @notice Tracks whether a reviewer has already voted on a specific milestone request version
    /// @dev keccak(roundId, stage, requestId) => reviewer => voted
    mapping(bytes32 => mapping(address => bool)) private _milestoneVotes;

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the GrantManager contract
     * @dev Sets up the initial contract addresses for the DAO ecosystem
     * @param _votingSystem Address of the VotingSystem contract
     * @param _fundingPool Address of the FundingPool contract
     * @param _ideaRegistry Address of the IdeaRegistry contract
     * @param _rolesRegistry Address of the RolesRegistry contract
     * @custom:emits GrantManagerInitialized
     * @custom:requires All addresses must be non-zero
     */
   function initialize(
        address _votingSystem,
        address _fundingPool,
        address _ideaRegistry,
        address _rolesRegistry
    ) public initializer  {
        __ReentrancyGuard_init();
        __Pausable_init();

        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");

        __RolesAware_init(_rolesRegistry);

        if (_votingSystem == address(0)) revert ZeroAddress("votingSystem");
        if (_fundingPool == address(0)) revert ZeroAddress("fundingPool");
        if (_ideaRegistry == address(0)) revert ZeroAddress("ideaRegistry");

        votingSystem = IVotingSystem(_votingSystem);
        fundingPool = IFundingPool(_fundingPool);
        ideaRegistry = IIdeaRegistry(_ideaRegistry);
        authorSharePercent = 95; // 95%
        
        _pause();
        
        emit GrantManagerInitialized(msg.sender);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Claims author grant for a winning idea
     * @dev Distributes funds to the author of the winning idea and updates idea status to Funded
     * @param roundId The ID of the funding round
     * @custom:emits RoundFunded
     * @custom:requires Round must not already have funds distributed
     * @custom:requires Round must be ended
     * @custom:requires Round must have a valid winner (winningIdeaId > 0)
     * @custom:requires Winning idea must be in WonVoting status
     * @custom:requires Winning idea author must be valid (non-zero address)
     * @custom:requires Caller must be the author of the winning idea
     */
    function claimGrant(uint256 roundId) external nonReentrant whenNotPaused {
        GrantPayout storage payout = _grantPayouts[roundId];
        if (payout.initialClaimed || fundingPool.isDistributed(roundId)) {
            revert AlreadyDistributed(roundId);
        }

        (, , , , , bool ended , , , ) = votingSystem.getRoundInfo(roundId);
        if (!ended) {
            revert RoundNotEnded(roundId);
        }

        (uint256 winningIdeaId, ) = votingSystem.getRoundWinner(roundId);
        if (winningIdeaId == 0) {
            revert NoWinner(roundId);
        }

        IdeaStatus currentStatus = ideaRegistry.getStatus(winningIdeaId);
        if (currentStatus != IdeaStatus.WonVoting) {
            revert IdeaNotEligible(
                winningIdeaId,
                uint8(IdeaStatus.WonVoting),
                uint8(currentStatus)
            );
        }

        address author = ideaRegistry.getIdeaAuthor(winningIdeaId);
        if (author == address(0)) {
            revert InvalidAuthor();
        }
        if (msg.sender != author) {
            revert NotAuthor(msg.sender, author);
        }

        uint256 totalIdeaStake = fundingPool.poolByRoundAndIdea(roundId, winningIdeaId);
        if (totalIdeaStake == 0) {
            revert NoFundsAllocated(roundId, winningIdeaId);
        }
        uint256 authorAmount = (totalIdeaStake * authorSharePercent) / 100;
        uint256 protocolAmount = totalIdeaStake - authorAmount;
        uint256 initialPayout = (authorAmount * INITIAL_PAYOUT_PERCENT) / 100;
        
        try fundingPool.moveIdeaFundsToReserve(roundId, winningIdeaId, protocolAmount) {
            // success
        } catch {
            revert ExternalCallFailed("FundingPool", "moveIdeaFundsToReserve");
        }

        ideaRegistry.updateStatus(winningIdeaId, IdeaStatus.Funded);

        try fundingPool.distributeFunds(roundId, winningIdeaId, initialPayout) {
            payout.ideaId = winningIdeaId;
            payout.author = author;
            payout.totalGrant = authorAmount;
            payout.released = initialPayout;
            payout.initialClaimed = true;

            emit RoundFunded(roundId, winningIdeaId, initialPayout);
        } catch {
            revert ExternalCallFailed("FundingPool", "distributeFunds");
        }
    }

    /**
     * @notice Submits proof for the next eligible milestone payout stage
     * @dev The author can only have one active request per stage at a time.
     *      Stage configuration is derived on-chain:
     *      - stage 1 (`IN_PROCESS_STAGE`) => 3 approvals out of max 5 reviewers
     *      - stage 2 (`COMPLETION_STAGE`) => 2 approvals out of max 3 reviewers
     * @param roundId The ID of the funding round
     * @param stage Milestone stage identifier
     * @param metadataURI Off-chain metadata pointer with proof materials
     * @param details Short human-readable summary of the submission
     */
    function submitMilestoneProof(
        uint256 roundId,
        uint8 stage,
        string memory metadataURI,
        string memory details
    ) external nonReentrant whenNotPaused {
        if (bytes(metadataURI).length == 0) {
            revert ZeroLength("metadataURI");
        }

        GrantPayout storage payout = _grantPayouts[roundId];
        if (!payout.initialClaimed) {
            revert MilestoneNotEligible(roundId, stage);
        }
        if (msg.sender != payout.author) {
            revert NotAuthor(msg.sender, payout.author);
        }

        MilestoneRequest storage request = _milestoneRequests[roundId][stage];
        if (request.active) {
            revert MilestoneRequestActive(roundId, stage);
        }

        _validateMilestoneSubmission(roundId, stage, payout.ideaId, request.lastRejectedAt);

        request.requestId += 1;
        request.metadataURI = metadataURI;
        request.details = details;
        request.submittedAt = block.timestamp;
        request.approvals = 0;
        request.rejections = 0;
        request.active = true;

        if (stage == IN_PROCESS_STAGE) {
            request.maxReviewers = IN_PROCESS_MAX_REVIEWERS;
            request.approvalThreshold = IN_PROCESS_APPROVAL_THRESHOLD;
        } else if (stage == COMPLETION_STAGE) {
            request.maxReviewers = COMPLETION_MAX_REVIEWERS;
            request.approvalThreshold = COMPLETION_APPROVAL_THRESHOLD;
        } else {
            revert MilestoneNotEligible(roundId, stage);
        }

        emit MilestoneProofSubmitted(roundId, payout.ideaId, stage, request.requestId);
    }

    /**
     * @notice Reviews the active milestone proof request for a round
     * @dev Any address with `REVIEWER_ROLE` may participate until the reviewer cap is reached.
     *      The request resolves as soon as:
     *      - approvals reach the configured threshold, or
     *      - rejections make approval mathematically impossible, or
     *      - the reviewer cap is exhausted
     * @param roundId The ID of the funding round
     * @param stage Milestone stage identifier
     * @param approved True to approve the request, false to reject
     */
    function reviewMilestoneProof(
        uint256 roundId,
        uint8 stage,
        bool approved
    ) external nonReentrant whenNotPaused onlyReviewer {
        GrantPayout storage payout = _grantPayouts[roundId];
        if (!payout.initialClaimed) {
            revert MilestoneNotEligible(roundId, stage);
        }
        if (msg.sender == payout.author) {
            revert CannotReviewOwnIdea(payout.author);
        }

        MilestoneRequest storage request = _milestoneRequests[roundId][stage];
        if (!request.active) {
            revert NoActiveMilestoneRequest(roundId, stage);
        }

        if (request.approvals + request.rejections >= request.maxReviewers) {
            revert ReviewerLimitReached(roundId, stage, request.maxReviewers);
        }

        bytes32 voteKey = keccak256(abi.encodePacked(roundId, stage, request.requestId));
        if (_milestoneVotes[voteKey][msg.sender]) {
            revert MilestoneAlreadyReviewed(roundId, stage, msg.sender);
        }

        _milestoneVotes[voteKey][msg.sender] = true;

        if (approved) {
            request.approvals += 1;
        } else {
            request.rejections += 1;
        }

        emit MilestoneReviewed(roundId, stage, msg.sender, approved);

        if (request.approvals >= request.approvalThreshold) {
            _approveMilestone(roundId, stage, payout, request);
            return;
        }

        uint8 rejectionThreshold = request.maxReviewers - request.approvalThreshold + 1;
        if (
            request.rejections >= rejectionThreshold ||
            request.approvals + request.rejections >= request.maxReviewers
        ) {
            request.active = false;
            request.lastRejectedAt = block.timestamp;
            emit MilestoneRejected(roundId, payout.ideaId, stage, request.requestId);
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Calculates the distribution amounts for a given round and idea
     * @dev Helper function to preview distribution without executing it
     * @param roundId The ID of the funding round
     * @param ideaId The ID of the idea (should be the winning idea)
     * @return authorAmount Amount that would go to the author
     * @return protocolAmount Amount that would be kept by the protocol
     * @return totalAmount Total amount available for the idea in this round
     */
    function calculateDistribution(uint256 roundId, uint256 ideaId) 
        external 
        view 
        returns (
            uint256 authorAmount,
            uint256 protocolAmount,
            uint256 totalAmount
        ) 
    {
        totalAmount = fundingPool.poolByRoundAndIdea(roundId, ideaId);
        authorAmount = (totalAmount * authorSharePercent) / 100;
        protocolAmount = totalAmount - authorAmount;
    }

    /**
     * @notice Checks if a grant can be claimed for a specific round
     * @dev Validates all conditions required for grant claiming
     * @param roundId The ID of the funding round
     * @return canClaim True if grant can be claimed
     * @return reason Human-readable reason if cannot claim
     */
    function canClaimGrant(uint256 roundId) 
        external 
        view 
        returns (
            bool canClaim, 
            string memory reason
        ) 
    {
        if (_grantPayouts[roundId].initialClaimed || fundingPool.isDistributed(roundId)) {
            return (false, "Grant already distributed");
        }

        (, , , , , bool ended , , , ) = votingSystem.getRoundInfo(roundId);
        if (!ended) {
            return (false, "Round not ended");
        }

        (uint256 winningIdeaId, ) = votingSystem.getRoundWinner(roundId);
        if (winningIdeaId == 0) {
            return (false, "No winner for this round");
        }

        if (ideaRegistry.getStatus(winningIdeaId) != IdeaStatus.WonVoting) {
            return (false, "Idea not in WonVoting status");
        }

        address author = ideaRegistry.getIdeaAuthor(winningIdeaId);
        if (author == address(0)) {
            return (false, "Invalid author address");
        }

        uint256 totalStake = fundingPool.poolByRoundAndIdea(roundId, winningIdeaId);
        if (totalStake == 0) {
            return (false, "No funds allocated to this idea");
        }

        return (true, "Grant can be claimed");
    }

    /**
     * @notice Gets the winning idea and author for a specific round
     * @param roundId The ID of the funding round
     * @return winningIdeaId The ID of the winning idea
     * @return author The address of the winning idea's author
     * @return ideaStatus The current status of the winning idea
     */
    function getRoundInfo(uint256 roundId) 
        external 
        view 
        returns (
            uint256 winningIdeaId,
            address author,
            IdeaStatus ideaStatus
        ) 
    {
        (winningIdeaId, ) = votingSystem.getRoundWinner(roundId);
        if (winningIdeaId != 0) {
            author = ideaRegistry.getIdeaAuthor(winningIdeaId);
            ideaStatus = ideaRegistry.getStatus(winningIdeaId);
        }
    }

    /**
     * @notice Gets the current protocol fee share
     * @dev Protocol share is calculated as 100% - authorSharePercent
     * @return uint256 Protocol share in basis points
     */
    function getProtocolShare() external view returns (uint256) {
        return 100 - authorSharePercent;
    }

    /**
     * @notice Returns payout tracking information for a round
     * @param roundId The ID of the funding round
     * @return ideaId Winning idea linked to the payout state
     * @return author Author entitled to receive payouts
     * @return totalGrant Total grant reserved for the author
     * @return released Total amount already released to the author
     * @return initialClaimed Whether the initial claim has already happened
     * @return inProcessPaid Whether the in-process tranche has been paid
     * @return completionPaid Whether the completion tranche has been paid
     */
    function getGrantPayout(uint256 roundId)
        external
        view
        returns (
            uint256 ideaId,
            address author,
            uint256 totalGrant,
            uint256 released,
            bool initialClaimed,
            bool inProcessPaid,
            bool completionPaid
        )
    {
        GrantPayout storage payout = _grantPayouts[roundId];
        return (
            payout.ideaId,
            payout.author,
            payout.totalGrant,
            payout.released,
            payout.initialClaimed,
            payout.inProcessPaid,
            payout.completionPaid
        );
    }

    /**
     * @notice Returns the latest milestone request state for a round and stage
     * @param roundId The ID of the funding round
     * @param stage Milestone stage identifier
     * @return requestId Sequential identifier for the current request version
     * @return metadataURI Off-chain pointer to milestone proof payload
     * @return details Human-readable proof summary
     * @return submittedAt Timestamp when the request was submitted
     * @return lastRejectedAt Timestamp of the previous rejection for cooldown tracking
     * @return approvals Number of approvals collected so far
     * @return rejections Number of rejections collected so far
     * @return maxReviewers Reviewer cap configured for the selected stage
     * @return approvalThreshold Number of approvals required for acceptance
     * @return active Whether the request is still open for review
     */
    function getMilestoneRequest(uint256 roundId, uint8 stage)
        external
        view
        returns (
            uint256 requestId,
            string memory metadataURI,
            string memory details,
            uint256 submittedAt,
            uint256 lastRejectedAt,
            uint8 approvals,
            uint8 rejections,
            uint8 maxReviewers,
            uint8 approvalThreshold,
            bool active
        )
    {
        MilestoneRequest storage request = _milestoneRequests[roundId][stage];
        return (
            request.requestId,
            request.metadataURI,
            request.details,
            request.submittedAt,
            request.lastRejectedAt,
            request.approvals,
            request.rejections,
            request.maxReviewers,
            request.approvalThreshold,
            request.active
        );
    }

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Updates the funding pool contract address
     * @dev Can only be called by the contract admin
     * @param _newPool New FundingPool contract address
     * @custom:emits FundingPoolUpdated
     * @custom:requires Only admin can call
     * @custom:requires _newPool cannot be zero address
     */
    function setFundingPool(address _newPool) external onlyAdmin {
        if (_newPool == address(0)) {
            revert ZeroAddress("newPool");
        }
        fundingPool = IFundingPool(_newPool);
        emit FundingPoolUpdated(_newPool);
    }

    /**
     * @notice Updates the idea registry contract address
     * @dev Can only be called by the contract admin
     * @param _newRegistry New IdeaRegistry contract address
     * @custom:emits IdeaRegistryUpdated
     * @custom:requires Only admin can call
     * @custom:requires _newRegistry cannot be zero address
     */
    function setIdeaRegistry(address _newRegistry) external onlyAdmin {
        if (_newRegistry == address(0)) {
            revert ZeroAddress("newRegistry");
        }
        ideaRegistry = IIdeaRegistry(_newRegistry);
        emit IdeaRegistryUpdated(_newRegistry);
    }

    /**
     * @notice Updates the voting system contract address
     * @dev Can only be called by the contract admin
     * @param _newVoting New VotingSystem contract address
     * @custom:emits VotingSystemUpdated
     * @custom:requires Only admin can call
     * @custom:requires _newVoting cannot be zero address
     */
    function setVotingSystem(address _newVoting) external onlyAdmin {
        if (_newVoting == address(0)) {
            revert ZeroAddress("newVoting");
        }
        votingSystem = IVotingSystem(_newVoting);
        emit VotingSystemUpdated(_newVoting);
    }

    /**
     * @notice Updates the author's share percentage
     * @dev Can only be called by the contract admin. Share is in basis points (95 = 95%)
     * @param newSharePercent New author share in basis points (must be ≤ 100)
     * @custom:emits FeeUpdated
     * @custom:requires Only admin can call
     * @custom:requires newShareBps must be ≤ 100
     */
    function setAuthorShare(uint256 newSharePercent) external onlyAdmin {
        if (newSharePercent > 100) {
            revert InvalidShare(newSharePercent, 100);
        }
        authorSharePercent = newSharePercent;
        emit FeeUpdated(authorSharePercent, 100 - authorSharePercent);
    }

    /* ========== PAUSE FUNCTIONS ========== */

    /**
     * @notice Emergency pause the voting system
     * @dev Only admin can pause. Stops all critical operations.
     * @custom:requires Only admin can call
     */
    function pause() external onlyAdmin {
        _pause();
    }

    /**
     * @notice Unpause the voting system
     * @dev Only admin can unpause. Resumes normal operations.
     * @custom:requires Only admin can call
     */
    function unpause() external onlyAdmin {
        _unpause();
    }

    /**
     * @notice Check if contract is paused
     * @return bool True if contract is paused
     */
    function isPaused() external view returns (bool) {
        return paused();
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /**
     * @notice Validates whether a milestone submission can be created for the given stage
     * @dev This function enforces the grant flow:
     *      - stage 1 is available only after initial funding and only while the idea is `Funded`
     *      - stage 2 is available only after the in-process tranche was paid and only while the idea is `InProcess`
     *      - rejected requests must respect the resubmission cooldown
     * @param roundId Round identifier
     * @param stage Milestone stage identifier
     * @param ideaId Winning idea identifier
     * @param lastRejectedAt Timestamp of the last rejection for this stage
     */
    function _validateMilestoneSubmission(
        uint256 roundId,
        uint8 stage,
        uint256 ideaId,
        uint256 lastRejectedAt
    ) internal view {
        if (stage == IN_PROCESS_STAGE) {
            if (_grantPayouts[roundId].inProcessPaid || ideaRegistry.getStatus(ideaId) != IdeaStatus.Funded) {
                revert MilestoneNotEligible(roundId, stage);
            }
        } else if (stage == COMPLETION_STAGE) {
            if (_grantPayouts[roundId].completionPaid || !_grantPayouts[roundId].inProcessPaid) {
                revert MilestoneNotEligible(roundId, stage);
            }
            if (ideaRegistry.getStatus(ideaId) != IdeaStatus.InProcess) {
                revert MilestoneNotEligible(roundId, stage);
            }
        } else {
            revert MilestoneNotEligible(roundId, stage);
        }

        if (lastRejectedAt != 0) {
            uint256 retryAt = lastRejectedAt + MILESTONE_RESUBMIT_COOLDOWN;
            if (block.timestamp < retryAt) {
                revert MilestoneCooldownActive(roundId, stage, retryAt);
            }
        }
    }

    /**
     * @notice Finalizes an approved milestone and releases the corresponding payout tranche
     * @dev Also advances the idea lifecycle in `IdeaRegistry`:
     *      - approved stage 1 moves the idea into `InProcess`
     *      - approved stage 2 marks the idea as `Completed`
     * @param roundId Round identifier
     * @param stage Milestone stage identifier
     * @param payout Stored payout data for the round
     * @param request Stored milestone request data for the round/stage
     */
    function _approveMilestone(
        uint256 roundId,
        uint8 stage,
        GrantPayout storage payout,
        MilestoneRequest storage request
    ) internal {
        uint256 amount = _milestoneAmount(payout.totalGrant, stage);

        try fundingPool.distributeFunds(roundId, payout.ideaId, amount) {
            payout.released += amount;
            request.active = false;

            if (stage == IN_PROCESS_STAGE) {
                payout.inProcessPaid = true;
                ideaRegistry.updateStatus(payout.ideaId, IdeaStatus.InProcess);
            } else {
                payout.completionPaid = true;
                ideaRegistry.markAsCompleted(payout.ideaId);
            }

            emit MilestoneApproved(roundId, payout.ideaId, stage, amount);
        } catch {
            revert ExternalCallFailed("FundingPool", "distributeFunds");
        }
    }

    /**
     * @notice Returns the author payout amount for a given milestone stage
     * @dev Stage 2 is computed as the remainder to avoid rounding drift across the 30/40/30 split
     * @param totalGrant Total author grant reserved for the round
     * @param stage Milestone stage identifier
     * @return uint256 Amount to release for the given stage
     */
    function _milestoneAmount(uint256 totalGrant, uint8 stage) internal pure returns (uint256) {
        uint256 initialPayout = (totalGrant * INITIAL_PAYOUT_PERCENT) / 100;
        uint256 inProcessPayout = (totalGrant * IN_PROCESS_PAYOUT_PERCENT) / 100;

        if (stage == IN_PROCESS_STAGE) {
            return inProcessPayout;
        }
        if (stage == COMPLETION_STAGE) {
            return totalGrant - initialPayout - inProcessPayout;
        }

        return 0;
    }

    /* ========== UPGRADE SAFETY ========== */

    /**
     * @notice Storage gap for future upgrades
     * @dev Reserved storage space to allow for new variables in upgrades
     * @dev Prevents storage collisions when adding new state variables
     * 
     * @custom:upgrade-safety Always include 50 slots gap in upgradeable contracts
     * @custom:warning Do not remove or reduce this gap in future versions
     */
    uint256[47] private __gap;
}
