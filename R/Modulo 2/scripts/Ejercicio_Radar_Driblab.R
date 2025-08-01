library(tidyverse)
library(ggtext)


# Este fichero rds lo tenéis también en soccerpizza con los datos necesarios de todos
# los jugadores

FBREF_Player_kpi_3<-readRDS('FBREF_Player_kpi_2.rds')

# El fichero tiene mucha info, nos quedamos con la que hace referencia a las métricas
# por 90' y el percentil para el total de los jugadores

FBREF_Player_kpi_3<-FBREF_Player_kpi_3 %>%
    select(Player,Position2,Squad,Season,variable,Type,value3,PCT3,MinPlayed)
names(FBREF_Player_kpi_3)<-c('Player','Position','Squad','Season','variable','Type','value2','PCT','MinPlayed')



# elegimos el primer jugador Carlos Soler
df_selected1<-FBREF_Player_kpi_3 %>%
  filter(Player=='Carlos Soler',
         Squad=='Valencia',
         Season=='2021/2022',
         variable %in% c(
                         'SCASCA',
                         'xA',
                         'KeyPass',
                         'Goals',
                         'Shots',
                         'xG',
                         'PassCompleted',
                         'PassProgressive',
                         'Touches',
                         'Carries',
                         'DribblesSuc',
                         'CarriesProgDist')) %>%
  arrange(Type) %>%
  ungroup()
# elegimos el primer jugador Vinicius
df_selected2<-FBREF_Player_kpi_3 %>%
  filter(Player=='Vinicius Júnior',
         Squad=='Real Madrid',
         Season=='2021/2022',
         variable %in% c(
                         'SCASCA',
                         'xA',
                         'KeyPass',
                         'Goals',
                         'Shots',
                         'xG',
                         'PassCompleted',
                         'PassProgressive',
                         'Touches',
                         'Carries',
                         'DribblesSuc',
                         'CarriesProgDist')) %>%
  arrange(Type) %>%
  ungroup()

# Colores para cada jugador
Playercolor3<-c('#A8C1E0')
Playercolor4<-c('#B5B5B5')

# Creamos un element text para el titulo con los colores y los datos de cada jugador
titulo=paste0("<b> <span style = 'color:",Playercolor3,";'**>",df_selected1$Player[1]," | ",df_selected1$Position[1]," | ",df_selected1$Squad[1]," | Mins Played: ",df_selected1$MinPlayed[1]," | Season: ",df_selected1$Season[1],"</span>",
              "<br><br>",
              "<b> <span style = 'color:",Playercolor4,";'**>",df_selected2$Player[1]," | ",df_selected2$Position[1]," | ",df_selected2$Squad[1]," | Mins Played: ",df_selected2$MinPlayed[1]," | Season: ",df_selected2$Season[1],"</span>",
              "<br>",sep="")


# Aquí viene algo interesante.
# Vamos a unir ambos jugadores para sacar el máximo de cada métrica
# así podemos ajustar el eje de cada métrica al máximo de cada métrica más un 10% para que
# haya un poco de hueco. Así evitamos esos radares feos con todo agrupado en el 0

df_total<-bind_rows(df_selected1,df_selected2)


# agrupamos por variable pero fijaros que no hacemos summarise
# el resultado será un df de las mismas filas, pero el calculo de maxvalue es
# teniendo el cuenta el agrupado de variable
df_total <- df_total %>%
  group_by(variable) %>%
  mutate(maxvalue=max(value2)) %>%
  ungroup() %>%
  # Como puede darse el caso que ambos jugadores tengan una métrica a 0
  # y por tanto el máximo será 0 le decimos que en ese caso, el máximo sea 1.
  # y ojo, si no es 0 el máximo valor lo incrementamos un 10% -> x . 1,1
  mutate(maxvalue=case_when(
    maxvalue==0 ~ 1,
    TRUE ~ maxvalue*1.1
  ))

# Ahora creamos un df con los valores máximos que ya tenemos y creamos un jugador
# ficticio llamado "Máximo"
maximo<-df_total %>%
  select(5,6,10) %>%
  mutate(Player="Maximo",
         value2=maxvalue) %>%
  select(1,2,3,4,5)

# Y se lo añadimos a df_total
df_total<-bind_rows(df_total,maximo)
df_total<-distinct(df_total)
# redondeamos decimales
df_total$value3<-round((df_total$value2/df_total$maxvalue)*100,2)



# Volvemos a separar los datos de los jugadores (no haría falta pero en otros tipos como hay
# alguna transformación más me toca separarlo, pero para este ejercicio no haría falta.

df_selected1<-df_total %>%
  filter(Player=='Carlos Soler',
         Squad=='Valencia',
         Season=='2021/2022',
         variable %in% c(
                        
                         'SCASCA',
                         'xA',
                         'KeyPass',
                         'Goals',
                         'Shots',
                         'xG',
                         'PassCompleted',
                         'PassProgressive',
                         'Touches',
                         'Carries',
                         'DribblesSuc',
                         'CarriesProgDist')) %>%
  arrange(Type) %>%
  ungroup()

df_selected2<-df_total %>%
  filter(Player=='Vinicius Júnior',
         Squad=='Real Madrid',
         Season=='2021/2022',
         variable %in% c(
                         'SCASCA',
                         'xA',
                         'KeyPass',
                         'Goals',
                         'Shots',
                         'xG',
                         'PassCompleted',
                         'PassProgressive',
                         'Touches',
                         'Carries',
                         'DribblesSuc',
                         'CarriesProgDist')) %>%
  arrange(Type) %>%
  ungroup()


# Ya tenemos los máximos y los datos de cada jugador. Pero tenemos que calcular los datos
# para poner en el eje en cada corte, recordemos que hay 4 cortes.
# nos quedamos con el jugador Maximo
quartiles<-df_total %>%
  filter(Player=="Maximo",
         variable %in% c(
                         'SCASCA',
                         'xA',
                         'KeyPass',
                         'Goals',
                         'Shots',
                         'xG',
                         'PassCompleted',
                         'PassProgressive',
                         'Touches',
                         'Carries',
                         'DribblesSuc',
                         'CarriesProgDist')) %>%
  arrange(Type) %>%
  ungroup() %>%
  # Aquí viene lo bueno. Lo que hago es calcular el valor
  # 25%, 50%, 75% y el 100% del valor máximo y que usaré para ponerlo como etiquetas en el eje
  mutate(`25`=round(maxvalue*0.25,2),
         `50`=round(maxvalue*0.5,2),
         `75`=round(maxvalue*0.75,2),
         `100`=round(maxvalue,2)) %>%
  ungroup() %>%
  select(5,6,12:15) %>%
  distinct()

# Tengo que pasarlo a formato long
quartiles<-reshape2::melt(quartiles)
names(quartiles)<-c('variable','Type','PCT','value')
# id mirando cada tabla lo que sale.



# y lo paso a factor y refactorizo ordenandolo por tipo, para que al pintarlo las métricas se ordenen
# por orden alfabetico dentro de cada tipo de métrica
quartiles$variable<-as.factor(quartiles$variable)
fct_reorder(quartiles$variable,quartiles$Type)
quartiles<-quartiles %>%
  arrange(Type,variable)
quartiles$PCT<-as.numeric(as.character(quartiles$PCT))


# Ahora vamos a girar las etiquetas de las variables. PAra eso
# hay un parámetro ang en geom_text y  angle en axis.text.x = element_text
temp <- (360/(length(df_selected1$Player))/2)
myAng <- seq(-temp, -360+temp, length.out = length(df_selected1$Player))
ang<-ifelse(myAng < -90, myAng+180, myAng)
ang<-ifelse(ang < -90, ang+180, ang)
# vemos que hay 18 angulos, 1 por variable
print(length(df_selected1$Player))

# Esto es para las etiquetas de los ejes. Lo de quartiles
# creo un df con los angulos anteriores, pero ojo, ahora tenemos que meter 4 etiquetas
# por eje, la p25, 50, 75 y 100.
ang2<-data.frame(orden=c(1:length(df_selected1$Player)),
                 ang=ang)
# Como tenemos 4 cortes, 25,50,75,100 vamos a recplicar el df 4 veces.
# la clave es el campo orden que metimos
n <- 4
ang2<-do.call("rbind", replicate(n, ang2, simplify = FALSE))

ang2<-ang2 %>%
  arrange(orden)

# refactorizamos los campos de los jugadores

df_selected1$variable<-as.factor(df_selected1$variable)
fct_reorder(df_selected1$variable,df_selected1$Type)
df_selected1<-df_selected1 %>%
  arrange(Type,variable)

df_selected2$variable<-as.factor(df_selected2$variable)
fct_reorder(df_selected2$variable,df_selected2$Type)
df_selected2<-df_selected2 %>%
  arrange(Type,variable)



# para crear las etiquetas de los ejes
to<-df_selected1 %>%
  select(value2,variable,Type) %>%
  inner_join(select(df_selected2,value2,variable,Type),by=c('variable'))
to<-to %>%
  mutate(label=paste0("<span><b>",variable,"</b></span><br> <span style='color:blue'>",round(value2.x,2),
                      "</span> vs <span style='color:black'>",round(value2.y,2),'</span>'))


ggplot(df_selected1, aes(fct_reorder(variable,Type),value3))+
  geom_rect(aes(xmin=-Inf, xmax=Inf, ymin=0, ymax=25), fill="gray65", alpha=0.5) +
  geom_rect(aes(xmin=-Inf, xmax=Inf, ymin=25, ymax=50), fill="gray75", alpha=0.5) +
  geom_rect(aes(xmin=-Inf, xmax=Inf, ymin=50, ymax=75), fill="gray85", alpha=0.5) +
  geom_rect(aes(xmin=-Inf, xmax=Inf, ymin=75, ymax=100), fill="gray95", alpha=0.5) +
  geom_hline(yintercept=25, colour="gray45",alpha=0.8,size=0.5)+
  geom_hline(yintercept=50, colour="gray35",alpha=0.8,size=0.5)+
  geom_hline(yintercept=75, colour="gray45",alpha=0.8,size=0.5)+
  geom_hline(yintercept=100, colour="gray35",alpha=0.8,size=0.5)+
  geom_vline(aes(xintercept = which(levels(df_selected1$variable) %in% c('SCASCA',
                                                                         'xA',
                                                                         'KeyPass',
                                                                         'Goals',
                                                                         'Shots',
                                                                         'xG',
                                                                         'PassCompleted',
                                                                         'PassProgressive',
                                                                         'Touches',
                                                                         'Carries',
                                                                         'DribblesSuc',
                                                                         'CarriesProgDist'))),color="white",size=1) +
  # pintamos cada jugador
  geom_polygon(data=df_selected1,fill=Playercolor3,alpha=0.5, aes(fct_reorder(variable,Type),value3,group=Player),color="darkblue",size=1,stat="identity") +
  geom_polygon(data=df_selected2,fill=Playercolor4,alpha=0.5, aes(fct_reorder(variable,Type),value3,group=Player),color="black",size=1,stat="identity") +
  geom_point(data=df_selected1,alpha=1, aes(fct_reorder(variable,Type),value3,group=Player),color="darkblue",size=3,stat="identity") +
  geom_point(data=df_selected2,alpha=1, aes(fct_reorder(variable,Type),value3,group=Player),color="black",size=2,stat="identity") +
  geom_text(data = quartiles, aes(fct_reorder(variable,Type),PCT, label = round(value,2)),
            hjust=0.5,vjust=0,fontface="bold",size=3,color="gray10") + #angle=ang2$ang
  geom_richtext(data = to, aes(fct_reorder(variable,Type.x),130, label = label),
            hjust=0.5,vjust=0,fontface="bold",size=3,color="gray10",fill = NA, label.color = NA) + #angle=ang2$ang

  # aquí lo hacemos circular
  coord_polar() +
  # metemos un label de cada métrica de cada jugador
  # geom_text(data=df_selected1,aes(x=fct_reorder(variable,Type),y=120,hjust=0,
  #                                  label=round(value2,2),fill=Type),size=2,color=Playercolor3,show.legend = FALSE)+
  # geom_text(data=df_selected2,aes(x=fct_reorder(variable,Type),y=120,hjust=1.5,
  #                                  label=round(value2,2),fill=Type),size=2,color=Playercolor4,show.legend = FALSE)+
  # Aquí le decimos los colores de cada tipo de métrica que dispara contra el geom_bar
  scale_fill_manual(values=c("Possession" = 'goldenrod1',
                             "Attacking" = 'dodgerblue1',
                             "Defending" = 'brown1')) +
  scale_y_continuous(limits = c(-10,140))+
  scale_x_discrete(drop = FALSE) +
  labs(fill="",
       caption = "Data from StatsBomb via FBref. @Vdot_Spain.\n¿Quieres aprender a hacer gráficos como estos?",
       title=titulo,

       subtitle = paste0("Compared to Top 5 competitions | Scaled by 90' and Total Players",sep=""))+

  theme_minimal() +
  theme(plot.background = element_rect(fill = "white",color = "white"),
        panel.background = element_rect(fill = "white",color = "white"),
        legend.position = "top",
        legend.text = element_text(size=8),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.y = element_blank(),
        axis.text.x = element_blank(),
        #axis.text.x = element_text(size = 9,face = "bold",color="black",margin=margin(5,1,1,1)), #angle = ang
        text = element_text(family="helvetica",color="black",size=6),
        plot.title = element_markdown(hjust=0.5,family="helvetica",size=14),
        plot.subtitle = element_text(hjust=0.5,size=12),
        plot.caption = element_text(hjust=0.5,size=8),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.margin = margin(5,2,2,2),
        legend.box="vertical")



