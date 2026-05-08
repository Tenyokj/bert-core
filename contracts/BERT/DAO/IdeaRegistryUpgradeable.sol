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
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import { IIdeaRegistry } from "../interfaces/IIdeaRegistry.sol";
import { IReputationSystem } from "../interfaces/IReputationSystem.sol";
import { IVoterProgression } from "../interfaces/IVoterProgression.sol";
import { IFundingPool } from "../interfaces/IFundingPool.sol";
import "../utils/IdeaStatus.sol";
import "../utils/Errors.sol";

/**
 * @title IdeaRegistry
 * @notice Central registry for storing and managing ideas within the DAO ecosystem
 * @dev Manages idea lifecycle, metadata, status transitions, and voting data
 * @dev Upgradeable
 * 
 * @custom:version 1.1.1
 */
contract IdeaRegistryUpgradeable is 
    Initializable,
    ReentrancyGuardUpgradeable,
    RolesAwareUpgradeable,  
    IIdeaRegistry 
{
    /* ========== CONTRACTS ========== */

    /**
     * @notice ReputationSystem contract interface
     * @dev Used for reputation checks and initialization
     */
    IReputationSystem public reputationSystem;

    /**
     * @notice VoterProgression contract interface
     * @dev Used to track voter progression for winning votes
     */
    IVoterProgression public voterProgression;

    /**
     * @notice Counter for generating unique idea IDs
     * @dev Starts at 1, increments for each new idea
     */
    uint256 private _ideaIdCounter;
   
    /* ========== STRUCTS ========== */

    /**
     * @notice Structure representing a single idea
     * @param id Unique identifier of the idea
     * @param author Address of the idea creator
     * @param title Title of the idea
     * @param description Detailed description of the idea
     * @param link Optional external link (can be empty string)
     * @param createdAt Timestamp when the idea was created
     * @param totalVotes Cumulative votes received by the idea
     * @param isLowQuality Flag indicating if idea was marked as low quality
     * @param status Current lifecycle status of the idea
     */
    struct Idea {
        uint256 id;
        address author;
        string title;
        string description;
        string link;
        uint256 createdAt;
        uint256 totalVotes;
        bool isLowQuality;
        IdeaStatus status;
    }

    /**
     * @notice Structure representing a review for an idea
     * @param reviewer Address of the reviewer
     * @param comment Review comment text
     */
    struct Review {
        address reviewer;
        string comment;
    }

    /* ========== STORAGE ========== */

    /// @notice Canonical storage for every registered idea
    /// @dev ideaId => Idea
    mapping(uint256 => Idea) public ideas;

    /**
     * @notice Mapping from idea ID to array of reviews
     * @dev ideaId => Review[] 
     */
    mapping(uint256 => Review[]) public ideaReviews;
    
    /// @notice Reverse index of idea IDs authored by each address
    /// @dev author => ideaIds[]
    mapping(address => uint256[]) public authorIdeas;

    /**
     * @notice FundingPool contract interface
     * @dev Appended in v1.1.1 to preserve the original proxy storage layout
     */
    IFundingPool public fundingPool;

    /// @notice Minimum amount authors must stake to create an idea
    /// @dev Appended in v1.1.1 to preserve the original proxy storage layout
    uint256 public authorMinStake;

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the IdeaRegistry contract
     * @dev Sets the contract deployer as the initial owner
     * @param _reputationSystem Address of the ReputationSystem contract
     * @param _voterProgression Address of the VoterProgression contract
     * @param _rolesRegistry Address of the RolesRegistry contract
     * @custom:emits IdeaRegistryInitialized
     * @custom:requires All addresses must be non-zero
     */
    function initialize(
        address _reputationSystem, 
        address _voterProgression,
        address _rolesRegistry
    ) public initializer {
        __ReentrancyGuard_init();

        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");

        __RolesAware_init(_rolesRegistry);
        
        if (_reputationSystem == address(0)) revert ZeroAddress("reputationSystem"); 
        if (_voterProgression == address(0)) revert ZeroAddress("voterProgression");
    
        reputationSystem = IReputationSystem(_reputationSystem);
        voterProgression = IVoterProgression(_voterProgression);
        _ideaIdCounter = 1;
        authorMinStake = 5000 * 10**18;
        
        emit IdeaRegistryInitialized(msg.sender);
    }

    /**
     * @notice Initializes V2-specific storage introduced after the original proxy deployment
     * @dev Must be executed immediately after upgrading an existing v1 proxy.
     *      Appending new storage and using a reinitializer prevents storage-slot collisions
     *      with the original `_ideaIdCounter` and mappings.
     * @param _fundingPool Address of the FundingPool contract
     * @param _authorMinStake Minimum amount authors must stake to create an idea
     */
    function initializeV2(
        address _fundingPool,
        uint256 _authorMinStake
    ) public reinitializer(2) {
        if (_fundingPool == address(0)) {
            revert ZeroAddress("fundingPool");
        }
        if (_authorMinStake == 0) {
            revert ZeroAmount();
        }

        fundingPool = IFundingPool(_fundingPool);
        authorMinStake = _authorMinStake;

        emit FundingPoolUpdated(_fundingPool);
        emit AuthorMinStakeUpdated(_authorMinStake);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Creates a new idea and locks the author's stake in the funding pool
     * @dev Idea starts with Pending status and zero votes. Initializes author's reputation if needed.
     * @param _title Title of the idea
     * @param _description Detailed description of the idea
     * @param _link Optional external link (can be empty string)
     * @param _amount Amount to stake on idea creation
     * @custom:emits IdeaCreated
     * @custom:requires _title cannot be empty
     * @custom:requires _description cannot be empty
     * @custom:requires _amount >= authorMinStake
     */
    function createIdea(
        string memory _title,
        string memory _description,
        string memory _link,
        uint256 _amount
    ) external nonReentrant {
        _createIdea(_title, _description, _link, _amount);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /**
     * @notice Internal idea creation flow shared by the external entrypoint
     * @dev Flow:
     *      1. validate metadata and stake amount
     *      2. ensure the funding pool is configured
     *      3. lazily initialize author reputation if needed
     *      4. lock the author's stake inside the funding pool
     *      5. store the new idea in `Pending` status
     * @param _title Title of the idea
     * @param _description Detailed description of the idea
     * @param _link Optional external link
     * @param _amount Amount to stake on idea creation
     */
    function _createIdea(
        string memory _title,
        string memory _description,
        string memory _link,
        uint256 _amount
    ) internal {
        if (bytes(_title).length == 0) {
            revert ZeroLength("title");
        }
        if (bytes(_description).length == 0) {
            revert ZeroLength("description");
        }
        if (address(fundingPool) == address(0)) {
            revert FundingPoolNotConfigured();
        }
        if (_amount < authorMinStake) {
            revert InsufficientStake(_amount, authorMinStake);
        }

        IERC20 token = IERC20(fundingPool.governanceToken());
        uint256 balance = token.balanceOf(msg.sender);
        if (balance < _amount) {
            revert InsufficientTokenBalance(balance, _amount);
        }

        uint256 allowance = token.allowance(msg.sender, address(fundingPool));
        if (allowance < _amount) {
            revert InsufficientAllowance(allowance, _amount);
        }

        if (!reputationSystem.isInitialized(msg.sender)) {
            try reputationSystem.initializeReputation(msg.sender) {
                // success
            } catch {
                revert ExternalCallFailed("ReputationSystem", "initializeReputation");
            }
        }

        uint256 newId = _ideaIdCounter;

        try fundingPool.depositAuthorStakeFrom(msg.sender, newId, _amount) {
            // success
        } catch {
            revert ExternalCallFailed("FundingPool", "depositAuthorStakeFrom");
        }

        ideas[newId] = Idea({
            id: newId,
            author: msg.sender,
            title: _title,
            description: _description,
            link: _link,
            createdAt: block.timestamp,
            totalVotes: 0,
            isLowQuality: false,
            status: IdeaStatus.Pending
        });

        authorIdeas[msg.sender].push(newId);
        emit IdeaCreated(newId, msg.sender, _title);

        _ideaIdCounter++;
    }

    /**
     * @notice Updates the status of an existing idea
     * @dev Only callable by authorized roles (Voting System or Grant Manager).
     *      The state machine is intentionally strict:
     *      `Pending -> Voting -> WonVoting/Rejected -> Funded -> InProcess -> Completed`
     *      Rejected and completed ideas are terminal.
     * @param ideaId ID of the idea to update
     * @param newStatus New status for the idea
     * @custom:emits IdeaStatusUpdated
     * @custom:requires ideaId must exist (1 <= ideaId < _ideaIdCounter)
     * @custom:requires newStatus must be different from current status
     * @custom:requires status transition must follow valid state machine rules
     */
    function updateStatus(
        uint256 ideaId,
        IdeaStatus newStatus
    ) external onlyVotingSystemOrGrantManager {
        if (ideaId == 0 || ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(ideaId);
        }

        IdeaStatus current = ideas[ideaId].status;
        if (current == newStatus) {
            revert StatusUnchanged(current);
        }

        if (current == IdeaStatus.Pending) {
            if (newStatus != IdeaStatus.Voting) {
                revert InvalidTransition(current, newStatus);
            }
        }
        else if (current == IdeaStatus.Voting) {
            if (newStatus != IdeaStatus.WonVoting && newStatus != IdeaStatus.Rejected) {
                revert InvalidTransition(current, newStatus);
            }
        }
        else if (current == IdeaStatus.WonVoting) {
            if (newStatus != IdeaStatus.Funded) {
                revert InvalidTransition(current, newStatus);
            }
        }
        else if (current == IdeaStatus.Funded) {
            if (newStatus != IdeaStatus.InProcess) {
                revert InvalidTransition(current, newStatus);
            }
        }
        else if (current == IdeaStatus.InProcess) {
            if (newStatus != IdeaStatus.Completed) {
                revert InvalidTransition(current, newStatus);
            }
        }
        else {
            revert TerminalStatus(current);
        }

        if (newStatus == IdeaStatus.Rejected) {
            try fundingPool.slashAuthorStakeToReserve(ideaId) {
                // success
            } catch {
                revert ExternalCallFailed("FundingPool", "slashAuthorStakeToReserve");
            }
        }

        ideas[ideaId].status = newStatus;
        emit IdeaStatusUpdated(ideaId, newStatus);
    }

    /**
     * @notice Manually adds votes to an idea
     * @dev Primarily for administrative adjustments and testing. Only callable by VOTING_ROLE.
     * @param ideaId ID of the idea receiving votes
     * @param amount Number of votes to add
     * @custom:emits IdeaVoted
     * @custom:requires ideaId must exist
     * @custom:requires amount must be greater than zero
     * @custom:requires idea must be in Voting status
     */
    function addVote(uint256 ideaId, uint256 amount) external onlyVotingSystem {
        if (ideaId == 0 || ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(ideaId);
        }
        if (amount == 0) {
            revert ZeroVoteAmount();
        }

        Idea storage cIdea = ideas[ideaId];
        if (cIdea.status != IdeaStatus.Voting) {
            revert NotInVotingStatus(ideaId, cIdea.status);
        }

        cIdea.totalVotes += amount;
        emit IdeaVoted(ideaId, msg.sender, amount);
    }

    /**
     * @notice Marks an idea as low quality
     * @dev Only callable by CURATOR_ROLE. Idea must be in Voting status.
     * @param ideaId ID of the idea to mark as low quality
     * @custom:emits IdeaMarkedLowQuality
     * @custom:requires ideaId must exist
     * @custom:requires Msg.sender is not the author of the idea
     * @custom:requires idea must be in Voting status
     */
    function markLowQuality(uint256 ideaId) external onlyCurator {
        if (ideaId == 0 || ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(ideaId);
        }
        
        Idea storage idea = ideas[ideaId];
        
        if (msg.sender == idea.author) {
            revert CannotReviewOwnIdea(idea.author);
        }
        
        if (idea.status != IdeaStatus.Voting) {
            revert NotInVotingStatus(ideaId, idea.status);
        }
        
        if (idea.isLowQuality) {
            revert IdeaAlreadyLowQuality(ideaId);
        }

        ideas[ideaId].isLowQuality = true;
        emit IdeaMarkedLowQuality(ideaId, msg.sender);
    }

    /**
     * @notice Adds a review to an idea
     * @dev Only callable by REVIEWER_ROLE. Idea must be in Voting status.
     * @param ideaId ID of the idea to review
     * @param comment Review comment text
     * @custom:emits ReviewAdded
     * @custom:requires ideaId must exist
     * @custom:requires Msg.sender is not the author of the idea
     * @custom:requires idea must be in Voting status
     */
    function addReview(uint256 ideaId, string memory comment) external onlyReviewer {
        if (ideaId == 0 || ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(ideaId);
        }
        
        Idea storage idea = ideas[ideaId];
        
        if (msg.sender == idea.author) {
            revert CannotReviewOwnIdea(idea.author);
        }
        
        if (idea.status != IdeaStatus.Voting) {
            revert NotInVotingStatus(ideaId, idea.status);
        }

        ideaReviews[ideaId].push(Review({
            reviewer: msg.sender,
            comment: comment
        }));

        emit ReviewAdded(ideaId, msg.sender);
    }

    /**
     * @notice Marks idea status as completed after grant milestone approval
     * @param ideaId ID of the idea to mark
     * @custom:emits IdeaStatusUpdated
     * @custom:requires Caller has GRANT_ROLE
     * @custom:requires Idea status is marked as InProcess
     */
    function markAsCompleted(uint256 ideaId) external onlyGrantManager {
        if (ideaId == 0 || ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(ideaId);
        }
        
        Idea storage idea = ideas[ideaId];

        if (idea.status != IdeaStatus.InProcess) {
            revert NotInCorrectStatus(IdeaStatus.InProcess, idea.status);
        }

        ideas[ideaId].status = IdeaStatus.Completed;
        emit IdeaStatusUpdated(ideaId, IdeaStatus.Completed);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Retrieves all idea IDs created by a specific author
     * @param _author Address to query
     * @return Array of idea IDs created by the author
     */
    function getIdeasByAuthor(address _author) external view returns (uint256[] memory) {
        return authorIdeas[_author];
    }

    /**
     * @notice Retrieves the author address for a specific idea
     * @dev Optimized for external contracts needing only author information
     * @param ideaId ID of the idea to query
     * @return author Address of the idea creator
     * @custom:requires ideaId must exist
     */
    function getIdeaAuthor(uint256 ideaId) external view returns (address) {
        if (ideaId == 0 || ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(ideaId);
        }
        return ideas[ideaId].author;
    }

    /**
     * @notice Retrieves comprehensive idea data as separate return values
     * @param _ideaId ID of the idea to retrieve
     * @return id Unique identifier
     * @return author Creator address
     * @return title Idea title
     * @return description Detailed description
     * @return link External reference
     * @return createdAt Creation timestamp
     * @return totalVotes Cumulative votes received
     * @return status Current lifecycle status as uint8
     * @custom:requires _ideaId must exist
     */
    function getIdea(uint256 _ideaId) external view returns (
        uint256 id,
        address author,
        string memory title,
        string memory description,
        string memory link,
        uint256 createdAt,
        uint256 totalVotes,
        uint8 status
    ) {
        if (_ideaId == 0 || _ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(_ideaId);
        }

        Idea memory idea = ideas[_ideaId];
        return (
            idea.id,
            idea.author,
            idea.title,
            idea.description,
            idea.link,
            idea.createdAt,
            idea.totalVotes,
            uint8(idea.status)
        );
    }

    /**
     * @notice Retrieves complete idea structure
     * @param _ideaId ID of the idea to retrieve
     * @return Idea struct containing all idea data
     * @custom:requires _ideaId must exist
     */
    function getIdeaStruct(uint256 _ideaId) external view returns (Idea memory) {
        if (_ideaId == 0 || _ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(_ideaId);
        }
        return ideas[_ideaId];
    }

    /**
     * @notice Retrieves the status of an idea
     * @param _ideaId ID of the idea to query
     * @return Current status of the idea
     * @custom:requires _ideaId must exist
     */
    function getStatus(uint256 _ideaId) public view returns (IdeaStatus) {
        if (_ideaId == 0 || _ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(_ideaId);
        }
        return ideas[_ideaId].status;
    }

    /**
     * @notice Returns the total number of created ideas
     * @return Count of all ideas (counter - 1 since counter starts at 1)
     */
    function totalIdeas() external view returns (uint256) {
        return _ideaIdCounter - 1;
    }

    /**
     * @notice Retrieves reviews for a specific idea
     * @param ideaId ID of the idea
     * @return Array of Review structs for the idea
     */
    function getIdeaReviews(uint256 ideaId) external view returns (Review[] memory) {
        return ideaReviews[ideaId];
    }

    /**
     * @notice Retrieves the number of reviews for a specific idea
     * @param ideaId ID of the idea
     * @return Number of reviews for the idea
     */
    function getReviewCount(uint256 ideaId) external view returns (uint256) {
        return ideaReviews[ideaId].length;
    }

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Updates the ReputationSystem contract address
     * @dev Only callable by contract admin
     * @param _newReputationSystem New ReputationSystem contract address
     * @custom:requires _newReputationSystem cannot be zero address
     */
    function setReputationSystem(address _newReputationSystem) external onlyAdmin {
        if (_newReputationSystem == address(0)) {
            revert ZeroAddress("newReputationSystem");
        }
        reputationSystem = IReputationSystem(_newReputationSystem);
        emit ReputationSystemUpdated(_newReputationSystem);
    }

    /**
     * @notice Updates the VoterProgression contract address
     * @dev Only callable by contract admin
     * @param _newVoterProgression New VoterProgression contract address
     * @custom:requires _newVoterProgression cannot be zero address
     */
    function setVoterProgression(address _newVoterProgression) external onlyAdmin {
        if (_newVoterProgression == address(0)) {
            revert ZeroAddress("newVoterProgression");
        }
        voterProgression = IVoterProgression(_newVoterProgression);
        emit VoterProgressionUpdated(_newVoterProgression);
    }

    /**
     * @notice Updates the FundingPool contract address
     * @dev Only callable by contract admin
     * @dev Required for author stake locking and rejection slashing flow
     * @param _newFundingPool New FundingPool contract address
     */
    function setFundingPool(address _newFundingPool) external onlyAdmin {
        if (_newFundingPool == address(0)) {
            revert ZeroAddress("newFundingPool");
        }
        fundingPool = IFundingPool(_newFundingPool);
        emit FundingPoolUpdated(_newFundingPool);
    }

    /**
     * @notice Updates the minimum author stake amount
     * @dev Only callable by contract admin.
     *      All future idea submissions must stake at least this amount.
     * @param _newAuthorMinStake New minimum stake amount
     */
    function setAuthorMinStake(uint256 _newAuthorMinStake) external onlyAdmin {
        if (_newAuthorMinStake == 0) {
            revert ZeroAmount();
        }
        authorMinStake = _newAuthorMinStake;
        emit AuthorMinStakeUpdated(_newAuthorMinStake);
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
    uint256[48] private __gap;
}
