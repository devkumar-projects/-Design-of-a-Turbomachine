% Computes the electrical parameters (flux, EMF, and inductance) of a
% three-phase surface-mounted permanent-magnet machine with one slot
% per pole per phase, using the free FEMM solver (David Meeker).
% This MATLAB script uses the OctaveFEMM toolbox.
% See http://www.femm.info/Archives/doc/octavefemm.pdf
% Version 2025
% Base template: Jean-Frederic Charpentier (ENSAM course supervisor)

clear all;
close all;
% Set this path to the local FEMM installation directory
addpath C:\femm42\mfiles
savepath;
openfemm;
newdocument(0)
% degree-to-radian conversion factor
deg=pi/180;
% Design specification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P=6e3; 
 N=1500;
A=18000; 
J=4e6; 
kr=0.5; 
g=0.003;
X=0.5;
Br=1.2; 
Bsat=1.4; 
D=0.275;
Betaa=2/3; 
Von=200;
fmax=100; 
%ebec=15;
% Intermediate variables
R=D/2;
Omega=N*2*pi/60

% Sizing quantities to be calculated (example values shown below,
% to be replaced with the design point from the sizing model)


L=0.05;
ea=6e-3;
pmax=3;
ecul=2.e-2;
Betadmin=0.5;
penc=2e-2; 
ncondphase=300; 
Irms=A*pi*D/(3*ncondphase)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Geometric data (in mm)
% active axial length
prof=L*1000; 
% Air gap
entrefer=g*1000;
% Bore radius
Ral=D*1000/2;
% rotor yoke thickness
EculR=ecul*1000;
% stator yoke thickness
EculS=ecul*1000;
% magnet thickness
Ea=ea*1000;
% slot depth
Eenc=penc*1000;
% number of pole pairs
np=pmax;
% pole arc ratio
beta=Betaa;
% tooth-to-slot-pitch ratio
betad=Betadmin;
% slot-opening lip thickness
Pbec=3;
% slot-closure coefficient
ferm=0.7;
% machine-to-study-domain ratio
nd=2*np;
% Current
I=0;

% number of conductors per slot
Nt=ncondphase/(2*np);
% number of rotation steps over a half period
npas=40;
dtpas=180/(npas*np);
tta0=dtpas/2; 
%smartmesh(1)
% compute the principal radii
RintCR=Ral-entrefer-Ea-EculR;
RextCR=Ral-entrefer-Ea; 
RextA=Ral-entrefer;
Rag1=RextA+0.9*entrefer/2;
Rag2=RextA+1.1*entrefer/2;
Rag0=RextA+entrefer/2;
Rfe=Ral+Pbec+Eenc;
Rde=Ral+Pbec;
RextS=Ral+Eenc+EculS+Pbec;
Rme=(Ral+Pbec+Rfe)/2;
RmCR=(RintCR+RextCR)/2;

PasDent=180/(3*np);





% define materials and circuits
mi_probdef(0,'millimeters','planar', 1.e-8,prof,30);
mi_getmaterial('Air');
mi_getmaterial('Pure Iron');
mi_getmaterial('NdFeB 32 MGOe');
mi_addcircprop('A',I,1);
mi_addcircprop('B',-I,1);
mi_addcircprop('C',0,1);
% define boundary conditions
mi_addboundprop('A=0', 0, 0, 0, 0, 0, 0, 0, 0, 0);
mi_addboundprop('Ap1', 0, 0, 0, 0, 0, 0, 0, 0, 5);
mi_addboundprop('Ap2', 0, 0, 0, 0, 0, 0, 0, 0, 5);
mi_addboundprop('Ap3', 0, 0, 0, 0, 0, 0, 0, 0, 5);
mi_addboundprop('Ap4', 0, 0, 0, 0, 0, 0, 0, 0, 5);
mi_addboundprop('Ap5', 0, 0, 0, 0, 0, 0, 0, 0, 5);
mi_addboundprop('Ap6', 0, 0, 0, 0, 0, 0, 0, 0, 5);
% draw the rotor yoke
mi_addnode(RintCR, 0);
mi_addnode(RintCR*cos(2*pi/(2*np)),RintCR*sin(2*pi/(2*np)));
mi_addarc(RintCR, 0, RintCR*cos(2*pi/(2*np)),RintCR*sin(2*pi/(2*np)),360/(2*np),1);
mi_addnode(RextCR, 0);
mi_addnode(RextCR*cos(((1-beta)/2)*2*pi/(2*np)), RextCR*sin(((1-beta)/2)*2*pi/(2*np)));
mi_addnode(RextCR*cos(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np)), RextCR*sin(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np)));
mi_addnode(RextCR*cos(2*pi/(2*np)),RextCR*sin(2*pi/(2*np)));
mi_addarc(RextCR, 0, RextCR*cos(((1-beta)/2)*2*pi/(2*np)), RextCR*sin(((1-beta)/2)*2*pi/(2*np)),((1-beta)/2)*2*180/(2*np) ,1);
xint1=RextCR*cos(((1-beta)/2)*2*pi/(2*np));
yint1=RextCR*sin(((1-beta)/2)*2*pi/(2*np)); 
xint2=RextCR*cos(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np));
yint2=RextCR*sin(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np));
mi_addarc(xint1,yint1,xint2,yint2,beta*360/(2*np),1);
xint3=RintCR*cos(2*pi/(2*np));
yint3=RintCR*sin(2*pi/(2*np));
xo3=RextCR*cos(2*pi/(2*np));
yo3=RextCR*sin(2*pi/(2*np));
mi_addarc(xint2,yint2,xo3,yo3,((1-beta)/2)*2*180/(2*np),1);
mi_addsegment(RintCR, 0, RextCR, 0);
mi_addsegment(xint3,yint3,xo3,yo3);

% draw the magnets
xr31=RextA*cos(((1-beta)/2)*2*pi/(2*np));
yr31=RextA*sin(((1-beta)/2)*2*pi/(2*np));
xr32=RextA*cos(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np));
yr32=RextA*sin(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np));
mi_addnode(xr31,yr31);
mi_addnode(xr32,yr32);
mi_addarc(xr31,yr31,xr32,yr32,beta*360/(2*np),1);
mi_addsegment(xint1,yint1,xr31,yr31);
mi_addsegment(xint2,yint2,xr32,yr32);

% draw the rotor-side air region
mi_addnode(Rag1,0);
mi_addsegment(RextCR,0,Rag1,0); 
mi_addnode(Rag1*cos(2*pi/(2*np)),Rag1*sin(2*pi/(2*np)));
mi_addsegment(xo3,yo3,Rag1*cos(2*pi/(2*np)),Rag1*sin(2*pi/(2*np)));

% assign the rotor geometry to group 2 and set rotor boundary conditions
% nodes
mi_selectnode(RintCR, 0);
mi_selectnode(RintCR*cos(2*pi/(2*np)),RintCR*sin(2*pi/(2*np)));
mi_selectnode(RextCR, 0);
mi_selectnode(RextCR*cos(((1-beta)/2)*2*pi/(2*np)), RextCR*sin(((1-beta)/2)*2*pi/(2*np)));
mi_selectnode(RextCR*cos(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np)), RextCR*sin(2*pi/(2*np)-((1-beta)/2)*2*pi/(2*np)));
mi_selectnode(RextCR*cos(2*pi/(2*np)),RextCR*sin(2*pi/(2*np)));
mi_selectnode(xr31,yr31);
mi_selectnode(xr32,yr32);
mi_setnodeprop('<None>',2);
mi_clearselected;
% arcs
% inner arc
mi_selectarcsegment(RintCR*cos(2*pi/(4*np)),RintCR*sin(2*pi/(4*np)));
mi_setarcsegmentprop(1,'A=0',0,2);
mi_clearselected;
% other arcs
mi_selectarcsegment(RextCR*cos(2*pi/(4*np)),RextCR*sin(2*pi/(4*np)));
mi_selectarcsegment(RextCR*cos(0.5*(0.5-beta/2)*2*pi/(2*np)),RextCR*sin(0.5*(0.5-beta/2)*2*pi/(2*np)));
mi_selectarcsegment(RextCR*cos(0.5*(1.5+beta/2)*2*pi/(2*np)),RextCR*sin(0.5*(1.5+beta/2)*2*pi/(2*np)));
mi_selectarcsegment(RextA*cos(2*pi/(4*np)),RextA*sin(2*pi/(4*np)));
mi_setarcsegmentprop(1,'<None>',0,2);
mi_clearselected;
% segments
mi_selectsegment(0.5*(xint1+xr31),0.5*(yr31+yint1));
mi_selectsegment(0.5*(xint2+xr32),0.5*(yr32+yint2));
mi_setsegmentprop('<None>',0,1,0,2);
mi_clearselected;
% outer segments
mi_selectsegment(0.5*(RintCR+RextCR),0);
mi_selectsegment(0.5*(RextCR+RintCR)*cos(2*pi/(2*np)),0.5*(RextCR+RintCR)*sin(2*pi/(2*np)));
mi_setsegmentprop('Ap1',0,1,0,2);
mi_clearselected;

mi_selectsegment(0.5*(Rag1+RextCR),0);
mi_selectsegment(0.5*(Rag1+RextCR)*cos(2*pi/(2*np)),0.5*(Rag1+RextCR)*sin(2*pi/(2*np)));
mi_setsegmentprop('Ap2',0,1,0,2);
mi_clearselected;


% assign rotor materials
% yoke
RmCr=(RintCR+RextCR)/2;
mi_addblocklabel(RmCr*cos(pi/(2*np)),RmCr*sin(pi/(2*np)));
mi_selectlabel(RmCr*cos(pi/(2*np)),RmCr*sin(pi/(2*np)));
mi_setblockprop('Pure Iron', 1, 0, '<None>', 0, 2, 1);
mi_clearselected;
% magnet
RmA=(RextA+RextCR)/2;
mi_addblocklabel(RmA*cos(pi/(2*np)),RmA*sin(pi/(2*np)));
mi_selectlabel(RmA*cos(pi/(2*np)),RmA*sin(pi/(2*np)));
mi_setblockprop('NdFeB 32 MGOe', 1, 0, '<None>', 180/(2*np), 2, 1);
mi_clearselected;
% air gap
Rma=(RextA+Rag1)/2;
mi_addblocklabel(Rma*cos(pi/(2*np)),Rma*sin(pi/(2*np)));
mi_selectlabel(Rma*cos(pi/(2*np)),Rma*sin(pi/(2*np)));
mi_setblockprop('Air', 1, 0, '<None>', 0, 2, 1);
mi_clearselected;




% draw the stator-side air region
mi_addnode(Rag2,0);
mi_addnode(Ral,0);
mi_addsegment(Rag2,0,Ral,0); 
mi_addnode(Rag2*cos(2*pi/(2*np)),Rag2*sin(2*pi/(2*np)));
mi_addnode(Ral*cos(2*pi/(2*np)),Ral*sin(2*pi/(2*np)));
mi_addsegment(Rag2*cos(2*pi/(2*np)),Rag2*sin(2*pi/(2*np)),Ral*cos(2*pi/(2*np)),Ral*sin(2*pi/(2*np)) );
% draw the stator
% draw the slot region
mi_addnode(Rde*cos(0.5*betad*PasDent*deg),Rde*sin(0.5*betad*PasDent*deg));
mi_addnode(Rfe*cos(0.5*betad*PasDent*deg),Rfe*sin(0.5*betad*PasDent*deg));
mi_addnode(Rde*cos((1-0.5*betad)*PasDent*deg),Rde*sin((1-0.5*betad)*PasDent*deg));
mi_addnode(Rfe*cos((1-0.5*betad)*PasDent*deg),Rfe*sin((1-0.5*betad)*PasDent*deg));
angno=0.5*betad*PasDent*deg+0.5*ferm*(1-betad)*PasDent*deg;
mi_addnode(Rde*cos(angno),Rde*sin(angno));
mi_addnode(Ral*cos(angno),Ral*sin(angno));
angno1=(1-0.5*betad)*PasDent*deg-0.5*ferm*(1-betad)*PasDent*deg;
mi_addnode(Rde*cos(angno1),Rde*sin(angno1));
mi_addnode(Ral*cos(angno1),Ral*sin(angno1));

mi_addsegment(Rde*cos((1-0.5*betad)*PasDent*deg),Rde*sin((1-0.5*betad)*PasDent*deg),Rfe*cos((1-0.5*betad)*PasDent*deg),Rfe*sin((1-0.5*betad)*PasDent*deg));
mi_addsegment(Rde*cos(0.5*betad*PasDent*deg),Rde*sin(0.5*betad*PasDent*deg),Rfe*cos(0.5*betad*PasDent*deg),Rfe*sin(0.5*betad*PasDent*deg));
mi_addsegment(Rde*cos(angno),Rde*sin(angno), Ral*cos(angno),Ral*sin(angno));
mi_addsegment(Rde*cos(angno1),Rde*sin(angno1), Ral*cos(angno1),Ral*sin(angno1));

mi_addarc(Rde*cos(angno),Rde*sin(angno),Rde*cos(angno1),Rde*sin(angno1),(1-ferm)*(1-betad)*PasDent,1);
mi_addarc(Rfe*cos(0.5*betad*PasDent*deg),Rfe*sin(0.5*betad*PasDent*deg), Rfe*cos((1-0.5*betad)*PasDent*deg),Rfe*sin((1-0.5*betad)*PasDent*deg), betad*PasDent,1);

mi_addarc(Rde*cos(0.5*betad*PasDent*deg),Rde*sin(0.5*betad*PasDent*deg),Rde*cos(angno),Rde*sin(angno),0.5*ferm*(1-betad)*PasDent,1);
mi_addarc(Rde*cos(angno1),Rde*sin(angno1),Rde*cos((1-0.5*betad)*PasDent*deg),Rde*sin((1-0.5*betad)*PasDent*deg),0.5*ferm*(1-betad)*PasDent,1);

mi_addarc(Ral,0,Ral*cos(angno),Ral*sin(angno),angno/deg,1);


% select and rotate the slots (circular pattern)

mi_selectnode(Rde*cos(0.5*betad*PasDent*deg),Rde*sin(0.5*betad*PasDent*deg));
mi_selectnode(Rfe*cos(0.5*betad*PasDent*deg),Rfe*sin(0.5*betad*PasDent*deg));
mi_selectnode(Rde*cos((1-0.5*betad)*PasDent*deg),Rde*sin((1-0.5*betad)*PasDent*deg));
mi_selectnode(Rfe*cos((1-0.5*betad)*PasDent*deg),Rfe*sin((1-0.5*betad)*PasDent*deg));
mi_selectnode(Rde*cos(angno),Rde*sin(angno));
mi_selectnode(Ral*cos(angno),Ral*sin(angno));
mi_selectnode(Rde*cos(angno1),Rde*sin(angno1));
mi_selectnode(Ral*cos(angno1),Ral*sin(angno1));
mi_selectnode(Ral,0);
mi_copyrotate2(0,0,PasDent,2,0)
mi_clearselected;

mi_selectsegment(Rme*cos((1-0.5*betad)*PasDent*deg),Rme*sin((1-0.5*betad)*PasDent*deg));
mi_selectsegment(Rme*cos(0.5*betad*PasDent*deg),Rme*sin(0.5*betad*PasDent*deg));
mi_selectsegment(0.5*(Rde+Ral)*cos(angno),0.5*(Rde+Ral)*sin(angno));
mi_selectsegment(0.5*(Rde+Ral)*cos(angno1),0.5*(Rde+Ral)*sin(angno1));
mi_copyrotate2(0,0,PasDent,2,1);
mi_clearselected;

mi_selectarcsegment(Rde*cos(PasDent*deg/2), Rde*sin(PasDent*deg/2));
mi_selectarcsegment(Rfe*cos(PasDent*deg/2),Rfe*sin(PasDent*deg/2));
mi_selectarcsegment(Rde*cos(0.5*(0.5*betad*PasDent*deg+angno)),Rde*sin(0.5*(0.5*betad*PasDent*deg+angno)));
mi_selectarcsegment(Rde*cos(0.5*((1-0.5*betad)*PasDent*deg+angno1)),Rde*sin(0.5*((1-0.5*betad)*PasDent*deg+angno1)));
mi_selectarcsegment(Ral*cos(angno/2),Ral*sin(angno/2));
mi_copyrotate2(0,0,PasDent,2,3);
mi_clearselected;

mi_selectarcsegment(Ral*cos(angno/2),Ral*sin(angno/2));
mi_copyrotate2(0,0,angno1/deg,1,3);
mi_clearselected;
mi_selectarcsegment(Ral*cos(0.5*(angno1+PasDent*deg)),Ral*sin(0.5*(angno1+PasDent*deg)));
mi_copyrotate2(0,0,PasDent,2,3);
mi_clearselected;




% draw the stator yoke
mi_addnode(RextS,0); 
mi_addnode(RextS*cos(2*pi/(2*np)),RextS*sin(2*pi/(2*np)));
mi_addarc(RextS,0,RextS*cos(2*pi/(2*np)),RextS*sin(2*pi/(2*np)),360/(2*np),1);
mi_addsegment(Ral,0,RextS,0);
mi_addsegment(Ral*cos(2*pi/(2*np)),Ral*sin(2*pi/(2*np)),RextS*cos(2*pi/(2*np)),RextS*sin(2*pi/(2*np)));


% assign stator materials
% yoke
RmCs=(Rfe+RextS)/2;
mi_addblocklabel(RmCs*cos(pi/(2*np)),RmCs*sin(pi/(2*np)));
mi_selectlabel(RmCs*cos(pi/(2*np)),RmCs*sin(pi/(2*np)));
mi_setblockprop('Pure Iron', 1, 0, '<None>', 0, 1, 1);
mi_clearselected;
% Current

% slot 1
mi_addblocklabel(Rme*cos(PasDent*deg/2),Rme*sin(PasDent*deg/2));
mi_selectlabel(Rme*cos(PasDent*deg/2),Rme*sin(PasDent*deg/2));
mi_setblockprop('Air', 1, 0, 'A', 0, 3, Nt);
mi_clearselected;


% slot 2
mi_addblocklabel(Rme*cos(PasDent*deg/2+PasDent*deg),Rme*sin(PasDent*deg/2+PasDent*deg));
mi_selectlabel(Rme*cos(PasDent*deg/2+PasDent*deg),Rme*sin(PasDent*deg/2+PasDent*deg));
mi_setblockprop('Air', 1, 0, 'B', 0, 1, Nt);
mi_clearselected;

% slot 3
mi_addblocklabel(Rme*cos(PasDent*deg/2+2*PasDent*deg),Rme*sin(PasDent*deg/2+2*PasDent*deg));
mi_selectlabel(Rme*cos(PasDent*deg/2+2*PasDent*deg),Rme*sin(PasDent*deg/2+2*PasDent*deg));
mi_setblockprop('Air', 1, 0, 'C', 0, 1, Nt);
mi_clearselected;

% assign stator boundary conditions
mi_selectsegment(0.5*(Rag2+Ral),0);
mi_selectsegment(0.5*(Rag2+Ral)*cos(2*pi/(2*np)),0.5*(Rag2+Ral)*sin(2*pi/(2*np)));
mi_setsegmentprop('Ap4',0,1,0,1);
mi_clearselected;
mi_selectsegment(0.5*(Ral+RextS),0);
mi_selectsegment(0.5*(Ral+RextS)*cos(2*pi/(2*np)),0.5*(Ral+RextS)*sin(2*pi/(2*np)));
mi_setsegmentprop('Ap5',0,1,0,1);
mi_clearselected;
% inner arc
mi_selectarcsegment(RextS*cos(2*pi/(4*np)),RextS*sin(2*pi/(4*np)));
mi_setarcsegmentprop(1,'A=0',0,1);
mi_clearselected;
% save geometry
mi_saveas('geometrieMAP.fem');
mi_close;

for i=0:npas-1%
%for i=0:5
    
    tta=i*dtpas+tta0;
    ang(i+1)=tta;
    opendocument('geometrieMAP.fem');
    mi_selectgroup(2);
    mi_moverotate(0,0,tta);
    mi_clearselected;
    mi_addarc(Rag1,0,Rag2*cos(tta*deg),Rag2*sin(tta*deg),tta,1);
    mi_addarc(Rag1*cos(pi/np),Rag1*sin(pi/np),Rag2*cos(tta*deg+pi/np),Rag2*sin(tta*deg+pi/np),tta,1);
    mi_selectarcsegment(Rag0*cos(tta*deg/2),Rag0*sin(tta*deg/2));
    mi_selectarcsegment(Rag0*cos(pi/np+tta*deg/2),Rag0*sin(pi/np+tta*deg/2));
    mi_setarcsegmentprop(1,'Ap3',0,1);
    mi_clearselected;
    mi_zoomnatural();
    mi_saveas('temp.fem');
    mi_analyse;
    mi_loadsolution;
    
    
    % store the cogging torque
    mo_selectblock(RmA*cos(0.5*pi/np+tta*deg),RmA*sin(0.5*pi/np+tta*deg));
    mo_selectblock(RmCR*cos(0.5*pi/np+tta*deg),RmCR*sin(0.5*pi/np+tta*deg));
    det(i+1)=nd*mo_blockintegral(22);
    mo_clearblock;
    SurfaceE=Rme*PasDent*deg*(1-betad)*Eenc*1e-6;
    %flux Phase 1
    mo_selectblock(Rme*cos(0.5*PasDent*deg),Rme*sin(0.5*PasDent*deg));
    Flux1(i+1)=nd*Nt*mo_blockintegral(1)/SurfaceE;
    mo_clearblock;
    %flux Phase 2
    mo_selectblock(Rme*cos(1.5*PasDent*deg),Rme*sin(1.5*PasDent*deg));
    Flux2(i+1)=-nd*Nt*mo_blockintegral(1)/SurfaceE;
    mo_clearblock;
    %flux Phase 3
    mo_selectblock(Rme*cos(2.5*PasDent*deg),Rme*sin(2.5*PasDent*deg));
    Flux3(i+1)=nd*Nt*mo_blockintegral(1)/SurfaceE;
    mo_clearblock;
    mi_close;
    mo_close;
   
end
for j=0:npas-1
    ang(npas+j+1)=(npas+j)*dtpas+tta0;
    Flux1(npas+j+1)=-Flux1(j+1);
    Flux2(npas+j+1)=-Flux2(j+1);
    Flux3(npas+j+1)=-Flux3(j+1);
    det(npas+j+1)=det(j+1);
end

for j=1:2*npas-2
    fem1(j+1)=(Flux1(j+2)-Flux1(j))/(2*dtpas*deg);
    fem2(j+1)=(Flux2(j+2)-Flux2(j))/(2*dtpas*deg);
    fem3(j+1)=(Flux3(j+2)-Flux3(j))/(2*dtpas*deg);
end
fem1(1)= (Flux1(2)-Flux1(2*npas))/(2*dtpas*deg);   
fem1(2*npas)=(Flux1(1)-Flux1(2*npas-1))/(2*dtpas*deg);
fem2(1)= (Flux2(2)-Flux2(2*npas))/(2*dtpas*deg)   ;
fem2(2*npas)=(Flux2(1)-Flux2(2*npas-1))/(2*dtpas*deg);
fem3(1)= (Flux3(2)-Flux3(2*npas))/(2*dtpas*deg);  
fem3(2*npas)=(Flux3(1)-Flux3(2*npas-1))/(2*dtpas*deg);


%closefemm;


% calculation at position 0 with magnets neutralised and unit current in phase
% 1 (used to extract self- and mutual inductance)
opendocument('geometrieMAP.fem');
mi_modifycircprop('A',1,1);
mi_modifycircprop('B',1,0);
mi_modifycircprop('C',1,0);

mi_selectlabel(RmA*cos(pi/(2*np)),RmA*sin(pi/(2*np)));
mi_setblockprop('Air', 1, 0, '<None>', 0, 2, 1);
mi_clearselected;

mi_addsegment(Rag1,0,Rag2,0);
mi_addsegment(Rag1*cos(pi/np),Rag1*sin(pi/np),Rag2*cos(pi/np),Rag2*sin(pi/np));
mi_selectsegment(Rag0,0);
mi_selectsegment(Rag0*cos(pi/np),Rag0*sin(pi/np));
mi_setarcsegmentprop(1,'Ap3',0,1);
mi_setsegmentprop('Ap3', 0, 1, 0, 1)
mi_clearselected;
mi_zoomnatural();
mi_saveas('temp2.fem');
mi_analyse;
mi_loadsolution;
mo_selectblock(Rme*cos(0.5*PasDent*deg),Rme*sin(0.5*PasDent*deg));
Lxx=nd*Nt*mo_blockintegral(1)/SurfaceE;
mo_clearblock;
mo_selectblock(Rme*cos(2.5*PasDent*deg),Rme*sin(2.5*PasDent*deg));
Mxx=nd*Nt*mo_blockintegral(1)/SurfaceE;
mo_showdensityplot(1,0,0,2,'mag')

% Plot the field map at position 0


opendocument('geometrieMAP.fem');
mi_modifycircprop('A',1,0);
mi_modifycircprop('B',1,0);
mi_modifycircprop('C',1,0);

mi_selectlabel(RmA*cos(pi/(2*np)),RmA*sin(pi/(2*np)));
mi_setblockprop('NdFeB 32 MGOe', 1, 0, '<None>', 180/(2*np), 2, 1);
mi_clearselected;

mi_addsegment(Rag1,0,Rag2,0);
mi_addsegment(Rag1*cos(pi/np),Rag1*sin(pi/np),Rag2*cos(pi/np),Rag2*sin(pi/np));
mi_selectsegment(Rag0,0);
mi_selectsegment(Rag0*cos(pi/np),Rag0*sin(pi/np));
mi_setarcsegmentprop(1,'Ap3',0,1);
mi_setsegmentprop('Ap3', 0, 1, 0, 1)
mi_clearselected;
mi_zoomnatural();
mi_saveas('temp3.fem');
mi_analyse;
mi_loadsolution;
mo_showdensityplot(1,0,0,2,'mag')

% Plot flux linkage and EMF waveforms
figure(1);
plot(ang,Flux1,'b+-.');
hold on
plot(ang,Flux2,'k');
hold on
plot(ang,Flux3,'c+');
legend('Phase flux linkage');
figure(2)
plot(ang,fem1)
hold on
plot(ang,fem2,'k');
hold on
plot(ang,fem3,'c+');
legend('Phase EMF at Omega_m = 1 rad/s');
% figure(3)
% plot(ang,det);
% legend('Cogging torque');
for j=0:npas-1
    angelec(j+1)=(j+1)*180/npas
    Ic1(j+1)=1.41*Irms*cos(angelec(j+1)*pi/180);
    Ic2(j+1)=1.41*Irms*cos(angelec(j+1)*pi/180-2*pi/3);
    Ic3(j+1)=1.41*Irms*cos(angelec(j+1)*pi/180-4*pi/3);
    fem1bis(j+1)=fem1(j+1);
     fem2bis(j+1)=fem2(j+1);
      fem3bis(j+1)=fem3(j+1);
    Cem(j+1)=fem2(j+1)*Ic1(j+1)+fem1(j+1)*Ic2(j+1)+fem3(j+1)*Ic3(j+1);
    ang3(j+1)=angelec(j+1)/np;
    Ctot(j+1)=Cem(j+1)+det(j+1);
end
figure(3)
plot(ang3,Cem);
plot(ang3, Ctot); 
legend('Electromagnetic torque');
disp(['Self-inductance of one phase Lxx = ', num2str(Lxx)]);
disp(['Mutual inductance Mxy = ', num2str(Mxx)]);
