Perechislenija {#lists}
===========================

Sil'naja storona MarkDoshhn\ --- prostoj format dlja spiskov. Numeracija, kotoraja budet v itogovom dokumente,
opredeljaetsja v stilevom fajle, v Markdoshhn pol'zovatel' prosto vybiraet, budet li spisok numerovannym ili net.

Dokumentacija Pandoc s primerami razlichnyh spiskov [zdes'](http://pandoc.org/MANUAL.html#lists)

## Numerovannye spiski {#numlists}

Po standartu oformlenija dokumentacii Host e'lementy numerovannogo spiska pishutsja s zaglavnoj bukvy,
v konce vseh e'lementov, krome poslednego, stavitsja tochka s zapjatoj, posle poslednego e'lementa tochka.

Prostoj numerovannyj spisok (bez vlozhennosti):

1. Pervyj e'lement spiska;

1. Vtoroj e'lement spiska;

    E'lementy spiska mogut predstavljat' soboj gruppy iz neskol'kih paragrafov.

    Konechno, v MarkDoshhn prihoditsja prinimat' mery dlja togo, chtoby e'to bylo pravil'no vosprinjato `pandoc`-om.
    Paragrafy, krome pervogo pishutsja s otstupom.

    V poslednem paragrafe stavitsja libo tochka (kogda on poslednij v spiske), libo tochka s zapjatoj;

1. Tretij (i poslednij) e'lement spiska.

Numerovannyj spisok s vlozhennymi numerovannymi spiskami:

  1. Pervyj e'lement spiska;

     V pervom e'lemente vlozhennyj spisok:

     1. Vlozhennyj spisok, pervyj e'lement;
     2. Vlozhennyj spisok, vtoroj e'lement;
     3. Tretij e'lement vlozhennogo spiska.

  1. Vtoroj e'lement spiska;
     E'tot e'lement takzhe imeet slozhnuju strukturu, no vlozhen uzhe markirovannyj spisok.

     - vtoroj uroven' vlozhennosti;

        + tretij uroven' vlozhennosti;
        + tretij uroven' vlozhennosti.

     - vtoroj uroven' vlozhennosti.


  1. Tretij (i poslednij) e'lement spiska.

## Markirovannye spiski {#marklists}

Markirovannyj spisok neskol'ko proshhe numerovannogo. Nuzhno tol'ko zabotit'sja o tom,
chtoby markery raznyh urovnej vlozhennosti byli razlichny.

Markerami spiska mogut byt':

* zvjozdochka `*`;
* pljus `+`;
* defis (znak minus) `-`.

Smena markera pokazyvaet uroven' vlozhennosti.

* pervyj uroven' 1;
* pervyj uroven' 2;

    - vtoroj uroven' 2-1;
    - vtoroj uroven' 2-2.

* pervyj uroven' 3;

    - vtoroj uroven' 3-1;
    - vtoroj uroven' 3-2;

        + tretij uroven' 3-2-1;
        + tretij uroven' 3-2-2.

* pervyj uroven' 4;

Ne rekomenduetsja sozdavat' markirovannye spiski s urovnem vlozhennosti svyshe 2.

Po standartu oformlenija dokumentov HOST e'lementy markirovannogo spiska pishutsja s malen'koj bukvy, a v konce e'lementov,
krome poslednego, stavitsja tochka s zapjatoj.

Eshhjo odin markirovannyj spisok:

* pervyj e'lement;
* vtoroj e'lement.

Ne ochen' ponjatno, chto delat', kogda e'lementom markirovannogo spiska sluzhit paragraf teksta ili neskol'ko paragrafov.
Vozmozhno, v e'tom sluchae nuzhno vsjo-taki vse[^fn1] e'lementy spiska nachinat' s zaglavnoj bukvy.

[^fn1]: Dlja edinoobrazija, budet ploho smotret'sja, esli v odnom spiske budet i e'lementy s zaglavnoj bukvy, i so strochnoj.
