/********************************************************************************
*          Monte-Carlo Simulation for Light Transport in 3D Volumes             *
*********************************************************************************
*                                                                               *
* Copyright (C) 2002-2008,  David Boas    (dboas <at> nmr.mgh.harvard.edu)      *
*               2008        Jay Dubb      (jdubb <at> nmr.mgh.harvard.edu)      *
*               2008        Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)      *
*                                                                               *
* License:  4-clause BSD License, see LICENSE for details                       *
*                                                                               *
* Example:                                                                      *
*         tMCimg input.inp                                                      *
*                                                                               *
* Please find more details in README and doc/HELP                               *
********************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#define pi 3.1415926535897932f
#define C_VACUUM 2.9979e11f
#define TRUE 1
#define FALSE 0
#define MIN(a,b) ((a)<(b)?(a):(b))
#define FP_DIV_ERR  1e-8f
#define absf(x) ((x)>0? (x) : -(x))

/* MACRO TO CONVERT 3D INDEX TO LINEAR INDEX. */
#define mult2linear(i,j,k)  (tindex*nIxyz+((k)-Izmin)*nIxy+((j)-Iymin)*nIxstep+((i)-Ixmin))

#ifdef VOXSIZE_EQ_1
#define DIST2VOX(x,s) (((int)(x)))
#else
#define DIST2VOX(x,s) ((int)((x)*(s)))
#endif

#define EPS 2.2204e-16f

#ifdef SINGLE_PREC
#define READ_THREE_REALS "%f %f %f"
#define READ_REAL_INT_INT_INT "%f %d %d %d"
typedef float REAL;
#else
#define READ_THREE_REALS "%lf %lf %lf"
#define READ_REAL_INT_INT_INT "%lf %d %d %d"
typedef double REAL;
#endif

#define MAX_TISS_NUM  100
#define ASSERT(exp) tmc_assert(exp,__FILE__,__LINE__);

int idum;       /* SEED FOR RANDOM NUMBER GENERATOR - A LARGE NEGATIVE NUMBER IS REQUIRED */
void tmc_error(int id,const char *msg,const char *fname,const int linenum);
void tmc_assert(int ret,const char *fname,const int linenum);
int fgetl(FILE* fp, char* line, int size);

#define MAX_FILE_PATH 1024

int main( int argc, char *argv[] )
{
    int i,j,k,ii,jj;
    int N;                        /* NUMBER OF PHOTONS RUN SO FAR */
    int NT;                       /* TOTAL NUMBER OF PHOTONS TO RUN */
    int Ntissue;                  /* NUMBER OF TISSUE TYPES DESCRIBED IN THE IMAGE FILE */

    REAL foo;                   /* TEMPORARY VARIABLES */
    REAL ffoo;

    char ***tissueType;              /* STORE THE IMAGE FILE */
    short tissueIndex;
    int nxstep, nystep, nzstep;                   /* DIMENSIONS OF THE IMAGE FILE */
    REAL xstep, ystep, zstep, rxstep, rystep, rzstep, minstepsize;      /* VOXEL DIMENSIONS */

    REAL tmus[MAX_TISS_NUM], tmua[MAX_TISS_NUM];  /* OPTICAL PROPERTIES OF THE DIFFERENT TISSUE TYPES */
    REAL tg[MAX_TISS_NUM],   tn[MAX_TISS_NUM];

    REAL x,y,z;                 /* CURRENT PHOTON POSITION */
    REAL xi, yi, zi;            /* INITIAL POSITION OF THE PHOTON */

    REAL gg, phi,theta,sphi,cphi,stheta,ctheta; /* SCATTERING ANGLES */
    REAL c1,c2,c3;              /* DIRECTION COSINES */
    REAL c1o, c2o, c3o;         /* OLD DIRECTION COSINES */
    REAL cxi, cyi, czi;         /* INITIAL DIRECTION COSINES */

    REAL *II;             /* FOR STORING THE 2-PT FLUENCE */

    int Ixmin, Ixmax, Iymin, Iymax, Izmin, Izmax;   /* MIN AND MAX X,Y,Z FOR STORING THE */
    int nIxstep, nIystep, nIzstep;                  /*   2-PT FLUENCE */
    int nIxyz,nIxy;

    REAL minT, maxT;            /* MIN AND MAX TIME FOR SAMPLING THE 2-PT FLUENCE */
    REAL stepT, stepL;          /* TIME STEP AND CORRESPONDING LENGTH STEP FOR SAMPLING 
                                THE 2-PT FLUENCE */
    REAL stepT_r, stepT_too_small;   /* STEPT_R REMAINDER GATE WIDTH */

    REAL Lresid, Ltot, Lmin, Lmax, Lnext, step, nTstep_float;
    int nTstep, nTstep_int, tindex;

    int nDets;                    /* SPECIFY NUMBER OF DETECTORS*/
    REAL detRad;                 /* SPECIFY DETECTOR RADIUS */
    int **detLoc;                 /*    AND X,Y,Z LOCATIONS */
    REAL **detPos;                 /*    AND X,Y,Z LOCATIONS */


    REAL P2pt;                  /* PHOTON WEIGHT */

    REAL lenTiss[MAX_TISS_NUM];  /* THE LENGTH SPENT IN EACH TISSUE TYPE BY THE CURRENT PHOTON */
#ifdef MOMENTUM_TRANSFER
    REAL momTiss[MAX_TISS_NUM];  /* THE LENGTH SPENT IN EACH TISSUE TYPE BY THE CURRENT PHOTON */
#endif
    REAL rnm;                   /* RANDOM NUMBER */

    FILE *fp;                     /* FILE POINTERS FOR SAVING THE DATA */
    char filenm[MAX_FILE_PATH];      /* FILE NAME FOR DATA FILE */
    char segFile[MAX_FILE_PATH];     /* FILE NAME FOR IMAGE FILE */

    int sizeof_lenTissArray;
#ifdef MOMENTUM_TRANSFER
    int sizeof_momTissArray;
#endif

    /* GET THE COMMAND LINE ARGUMENTS */
    if( argc!=2) {
        printf( "usage: tMCimg input_file (.inp assumed)\n" );
        exit(1);
    }

    /*********************************************************
    OPEN AND READ THE INPUT FILE 
    *********************************************************/
    sprintf( filenm, "%s.inp", argv[1] );
    printf("Loading configurations from %s\n",filenm);
    if( (fp = fopen( filenm, "r" ))==NULL ) {
        printf( "usage: tMCimg input_file (.inp assumed)\n" );
        printf( "input_file = %s does not exist.\n", filenm );
        exit(1);
    }

    /* READ THE INPUT FILE */
    ASSERT(fscanf( fp, "%d", &NT )!=1);    /* TOTAL NUMBER OF PHOTONS */
    ASSERT(fscanf( fp, "%d", &idum )!=1);  /* RANDOM NUMBER SEED */
    ASSERT(fscanf( fp, READ_THREE_REALS, &xi, &yi, &zi )!=3);         /* INITIAL POSITION OF PHOTON */
    ASSERT(fscanf( fp, READ_THREE_REALS, &cxi, &cyi, &czi )!=3);      /* INITIAL DIRECTION OF PHOTON */
    ASSERT(fscanf( fp, READ_THREE_REALS, &minT, &maxT, &stepT )!=3);  /* MIN, MAX, STEP TIME FOR RECORDING */

    /* Calculate number of gates, taking into account floating point division errors. */
    nTstep_float = (maxT-minT)/stepT;
    nTstep_int   = (int)(nTstep_float);
    stepT_r      = absf(nTstep_float - nTstep_int) * stepT;
    stepT_too_small = FP_DIV_ERR * stepT;
    if(stepT_r < stepT_too_small)
        nTstep = nTstep_int;
    else
        nTstep = ceil(nTstep_float);

    /* READ SEG FILE NAME */
	ASSERT(fgetl(fp, segFile, sizeof(segFile))!=0);

    /* READ IMAGE DIMENSIONS */
    ASSERT(fscanf( fp, READ_REAL_INT_INT_INT, &xstep, &nxstep, &Ixmin, &Ixmax )!=4);
    ASSERT(fscanf( fp, READ_REAL_INT_INT_INT, &ystep, &nystep, &Iymin, &Iymax )!=4);
    ASSERT(fscanf( fp, READ_REAL_INT_INT_INT, &zstep, &nzstep, &Izmin, &Izmax )!=4);
    Ixmin--; Ixmax--; Iymin--; Iymax--; Izmin--; Izmax--;
    nIxstep = Ixmax-Ixmin+1;
    nIystep = Iymax-Iymin+1;
    nIzstep = Izmax-Izmin+1;

    minstepsize=MIN(xstep,MIN(ystep,zstep));  /*get the minimum dimension*/
    rxstep=1.f/xstep;
    rystep=1.f/ystep;
    rzstep=1.f/zstep;
    if(idum!=0) 
        srand(abs(idum));
    else {
        idum=time(NULL);
        srand(idum);
    }

    /* READ NUMBER OF TISSUE TYPES AND THEIR OPTICAL PROPERTIES */
    ASSERT(fscanf( fp, "%d", &Ntissue )!=1);
    tmus[0] = -999.f; tmua[0] = -999.f; tg[0] = -999.f; tn[0] = -999.f;
    for( i=1; i<=Ntissue; i++ ) {
#ifdef SINGLE_PREC
        ASSERT(fscanf( fp, "%f %f %f %f", &tmus[i], &tg[i], &tmua[i], &tn[i] )!=4);
#else
        ASSERT(fscanf( fp, "%lf %lf %lf %lf", &tmus[i], &tg[i], &tmua[i], &tn[i] )!=4);
#endif
        if( fabs(tn[i]-1.0f)>EPS ) {
            printf( "WARNING: The code does not yet support n!=1.0\n" );
        }
        if( fabs(tmus[i])<EPS ) {
            printf( "ERROR: The code does support mus = 0.0\n" );
            return(0);
        }
    }

    /* READ NUMBER OF DETECTORS, DETECTOR RADIUS, AND DETECTOR LOCATIONS */
#ifdef SINGLE_PREC
    ASSERT(fscanf( fp, "%d %f", &nDets, &detRad )!=2);
#else
    ASSERT(fscanf( fp, "%d %lf", &nDets, &detRad )!=2);
#endif
    detLoc = (int **)malloc(nDets*sizeof(int*));
    detPos = (REAL **)malloc(nDets*sizeof(REAL*));

    for( i=0; i<nDets; i++ ){
        detLoc[i] = (int *)malloc(3*sizeof(int));
        detPos[i] = (REAL *)malloc(3*sizeof(REAL));
    }
    for( i=0; i<nDets; i++ ) {
        ASSERT(fscanf( fp, READ_THREE_REALS, detPos[i], detPos[i]+1, detPos[i]+2 )!=3);
        detLoc[i][0]=(int)(detPos[i][0]*rxstep)-1;
        detLoc[i][1]=(int)(detPos[i][1]*rystep)-1;
        detLoc[i][2]=(int)(detPos[i][2]*rzstep)-1;
    }

    fclose(fp);


    /* NORMALIZE THE DIRECTION COSINE OF THE SOURCE */
    foo = sqrtf(cxi*cxi + cyi*cyi + czi*czi);  /*foo is the input */
    cxi /= foo;
    cyi /= foo;
    czi /= foo;


    /* CALCULATE THE MIN AND MAX PHOTON LENGTH FROM THE MIN AND MAX PROPAGATION TIMES */
    Lmax = maxT * C_VACUUM / tn[1];
    Lmin = minT * C_VACUUM / tn[1];
    stepL = stepT * C_VACUUM / tn[1];

    printf( "Loading target medium volume from %s\n", segFile );

    /* READ IN THE SEGMENTED DATA FILE */
    fp = fopen( segFile, "rb" );
    if( fp==NULL ) {
        printf( "ERROR: The binary image file %s was not found!\n", segFile );
        exit(1);
    }
    tissueType = (char ***)malloc(nxstep*sizeof(char **));
    for( i=0; i<nxstep; i++ ) {
        tissueType[i] = (char **)malloc(nystep*sizeof(char *));
        for( j=0; j<nystep; j++ ) {
            tissueType[i][j] = (char *)malloc(nzstep*sizeof(char));
        }
    }
    for( k=0; k<nzstep; k++ ) {
        for( j=0; j<nystep; j++ ) {
            for( i=0; i<nxstep; i++ ) {
                ASSERT(fscanf( fp, "%c", &tissueType[i][j][k] )!=1);
            }
        }
    }

    fclose(fp);


    nIxyz=nIzstep*nIxstep*nIystep;
    nIxy=nIxstep*nIystep;

    /* ALLOCATE SPACE FOR AND INITIALIZE THE PHOTON FLUENCE TO 0 */
    II = (REAL *)malloc(nIxyz*nTstep*sizeof(REAL));
    memset((void*)II,0,nIxyz*nTstep*sizeof(REAL));

    /* MAKE SURE THE SOURCE IS AT AN INTERFACE */
    i = DIST2VOX(xi,rxstep);
    j = DIST2VOX(yi,rystep);
    k = DIST2VOX(zi,rzstep);
    tissueIndex=tissueType[i][j][k];
    while( tissueIndex!=0 && i>0 && i<nxstep && j>0 && j<nystep && k>0 && k<nzstep ) {
		xi -= cxi*minstepsize;
		yi -= cyi*minstepsize;
		zi -= czi*minstepsize;
		i = DIST2VOX(xi,rxstep);
		j = DIST2VOX(yi,rystep);
		k = DIST2VOX(zi,rzstep);
		tissueIndex=tissueType[i][j][k];
    }
    while( tissueIndex==0 ) {
        xi += cxi*minstepsize;
        yi += cyi*minstepsize;
        zi += czi*minstepsize;
        i = DIST2VOX(xi,rxstep);
        j = DIST2VOX(yi,rystep);
        k = DIST2VOX(zi,rzstep);
        tissueIndex=tissueType[i][j][k];
    }


    /* NUMBER PHOTONS EXECUTED SO FAR */
    N = 0;

    /* OPEN A FILE POINTER TO SAVE THE HISTORY INFORMATION */
    sprintf( filenm, "%s.his", argv[1] );
    fp = fopen( filenm, "wb" );

    sizeof_lenTissArray = sizeof(REAL)*(Ntissue+1);
#ifdef MOMENTUM_TRANSFER
    sizeof_momTissArray = sizeof(REAL)*(Ntissue+1);
#endif
    /*********************************************************
    START MIGRATING THE PHOTONS 
    GENERATING PHOTONS UNTIL NUMBER OF PHOTONS EXECUTED
    (N) IS EQUAL TO THE NUMBER TO BE GENERATED (NT) 
    *********************************************************/

    printf("Launching %d photons\n", NT);

    while (N<NT){
        ++N;                                                                

        /* SET THE PHOTON WEIGHT TO 1 AND INITIALIZE PHOTON LENGTH PARAMETERS */
        P2pt = 1.f;
        Ltot = 0.f;
        Lnext = minstepsize;
        Lresid = 0.f;

        /* INITIALIZE THE LENGTH IN EACH TISSUE TYPE */
        memset((void*)lenTiss, 0, sizeof_lenTissArray);
#ifdef MOMENTUM_TRANSFER
        memset((void*)momTiss, 0, sizeof_momTissArray);
#endif    
        /* INITIAL SOURCE POSITION */
        x = xi;
        y = yi;
        z = zi;     

        /* INITIAL DIRECTION OF PHOTON */
        c1 = cxi;
        c2 = cyi;
        c3 = czi;
        c1o = c1;
        c2o = c2;
        c3o = c3;

        /* PROPAGATE THE PHOTON */
        i = DIST2VOX(x,rxstep);
        j = DIST2VOX(y,rystep);
        k = DIST2VOX(z,rzstep);

        /* LOOP UNTIL TIME EXCEEDS GATE OR PHOTON ESCAPES */
        while ( Ltot<Lmax && i>=0 && i<nxstep && j>=0 && j<nystep && k>=0 && k<nzstep && (tissueIndex=tissueType[i][j][k])!=0 ) {

            /* CALCULATE SCATTERING LENGTH */
            rnm = (REAL)rand()/RAND_MAX; /*ran( &idum, &ncall );*/
            if(rnm > EPS)
                Lresid = -logf(rnm);
            else
                Lresid = -logf(EPS);

            /* PROPAGATE THE PHOTON */
            while( Ltot<Lmax && Lresid>0. && i>=0 && i<nxstep && j>=0 && j<nystep && k>=0 && k<nzstep && (tissueIndex=tissueType[i][j][k])!=0 ) {

                if( Ltot>Lnext && Ltot>Lmin ) {
                    tindex = (int)((Ltot-Lmin)/stepL);
                    if ( i>=Ixmin && i<=Ixmax && j>=Iymin && j<=Iymax && k>=Izmin && k<=Izmax && tindex<nTstep) {
#ifdef DEBUG
                        printf("Scoring vox(%d,%d,%d) from photon %d at position (%0.1f,%0.1f,%0.1f) with fluence %f and direction (%0.1f,%0.1f,0.1%f)\n", 
                            i, j, k, N, x, y, z, P2pt, c1, c2, c3);
#endif            
                        II[mult2linear(i,j,k)] += P2pt;
                    }
                    Lnext += minstepsize;
                }

                /*if scattering length is likely within a voxel, i.e. jump inside one voxel*/
                if( (foo=tmus[tissueIndex])*minstepsize>Lresid ) { 
                    step = Lresid / foo;
                    x += c1*step;
                    y += c2*step;
                    z += c3*step;
                    Ltot += step;

                    P2pt *= exp(-tmua[tissueIndex] * step);

                    lenTiss[tissueIndex] += (REAL)step;
                    Lresid = 0.f;
                } else {   /*if scattering length is bigger than a voxel, then move 1 voxel*/
                    x += c1*minstepsize;
                    y += c2*minstepsize;
                    z += c3*minstepsize;
                    Ltot += minstepsize;

                    P2pt *= exp(-tmua[tissueIndex]*minstepsize);

                    Lresid -= foo*minstepsize;
                    lenTiss[tissueIndex] += minstepsize;
                }

                i = DIST2VOX(x,rxstep);
                j = DIST2VOX(y,rystep);
                k = DIST2VOX(z,rzstep);

            } /* PROPAGATE PHOTON */

            if(tissueIndex) {
                /* CALCULATE THE NEW SCATTERING ANGLE USING HENYEY-GREENSTEIN */
                gg = tg[tissueIndex];

                rnm = (REAL)rand()/RAND_MAX; /*ran( &idum, &ncall );*/
                phi=2.0f*pi*rnm;
                cphi=cosf(phi);
                sphi=sinf(phi);

                rnm = (REAL)rand()/RAND_MAX; /*ran( &idum, &ncall );*/
                if(gg > EPS) {
                    foo = (1.f - gg*gg)/(1.f - gg + 2.f*gg*rnm);
                    foo = foo * foo;
                    foo = (1.f + gg*gg - foo)/(2.f*gg);
                    theta=acosf(foo);
                    stheta=sinf(theta);
                    ctheta=foo;
                }else{  /*if g is exactly zero, then use isotropic scattering angle*/
                    theta=2.0f*pi*rnm;
                    stheta=sinf(theta);
                    ctheta=cosf(theta);
                }
#ifdef MOMENTUM_TRANSFER
                if(theta > 0.f)
                    momTiss[tissueIndex] += 1.f-ctheta;
#endif
                c1o = c1;
                c2o = c2;
                c3o = c3;
                if( c3<1.f && c3>-1.f ) {
                    c1 = stheta*(c1o*c3o*cphi - c2o*sphi)/sqrtf(1.f - c3o*c3o) + c1o*ctheta;
                    c2 = stheta*(c2o*c3o*cphi + c1o*sphi)/sqrtf(1.f - c3o*c3o) + c2o*ctheta;
                    c3 = -stheta*cphi*sqrtf(1-c3o*c3o)+c3o*ctheta;
                }
                else {
                    c1 = stheta*cphi;
                    c2 = stheta*sphi;
                    c3 = ctheta*c3;
                }
            } /* LOOP UNTIL END OF SINGLE PHOTON */
        }

        /* SCORE EXITING PHOTON AND SAVE HISTORY FILES*/
        i = DIST2VOX(x,rxstep);
        j = DIST2VOX(y,rystep);
        k = DIST2VOX(z,rzstep);

        if ( i>=0 && i<nxstep && j>=0 && j<nystep && k>=0 && k<nzstep ) {
            tissueIndex=tissueType[i][j][k];
            if( tissueIndex==0 ) {
                tindex = (int)((Ltot-Lmin)/stepL);
                if( i>=Ixmin && i<=Ixmax && j>=Iymin && j<=Iymax && k>=Izmin && k<=Izmax && tindex<nTstep ) {
#ifdef DEBUG
                    printf("Scoring air vox(%d,%d,%d) from photon %d at position (%0.1f,%0.1f,%0.1f) with fluence %f and direction (%0.1f,%0.1f,0.1%f)\n", 
                        i, j, k, N, x, y, z, P2pt, c1, c2, c3);
#endif
                    II[mult2linear(i,j,k)] -= P2pt;
                }

                /* LOOP THROUGH NUMBER OF DETECTORS */
                for( ii=0; ii<nDets; ii++ ) {
                    if( abs(x-detPos[ii][0])<=detRad )
                        if( abs(y-detPos[ii][1])<=detRad )
                            if( abs(z-detPos[ii][2])<=detRad ) {

                                /* WRITE TO THE HISTORY FILE */
                                ffoo = ii;
                                fwrite( &ffoo, sizeof(REAL), 1, fp );
                                for( jj=1; jj<=Ntissue; jj++ ) {
                                    fwrite( &lenTiss[jj], sizeof(REAL), 1, fp );
                                }
#ifdef MOMENTUM_TRANSFER
                                for( jj=1; jj<=Ntissue; jj++ ) {
                                    fwrite( &momTiss[jj], sizeof(REAL), 1, fp );
                                }
#endif
                            }
                }

                /* IF NO DETECTORS THEN SAVE EXIT POSITION */
                if( nDets==0 ) {
                    ffoo=i; fwrite( &ffoo, sizeof(REAL), 1, fp );
                    ffoo=j; fwrite( &ffoo, sizeof(REAL), 1, fp );
                    ffoo=k; fwrite( &ffoo, sizeof(REAL), 1, fp );
                    for( jj=1; jj<=Ntissue; jj++ ) {
                        fwrite( &lenTiss[jj], sizeof(REAL), 1, fp );
                    }
#ifdef MOMENTUM_TRANSFER
                    for( jj=1; jj<=Ntissue; jj++ ) {
                        fwrite( &momTiss[jj], sizeof(REAL), 1, fp );
                    }
#endif
                }
            }
        }


    } /* LOOP UNTIL ALL PHOTONS EXHAUSTED */

    /* CLOSE HISTORY FILE */
    fclose(fp); 


    /* SAVE FLUENCE DATA */
    sprintf( filenm, "%s.2pt", argv[1]);
    printf( "Save photon fluence distribution to %s\n", filenm);

    fp = fopen( filenm, "wb");
    if(fp!=NULL) {
        fwrite(II, sizeof(REAL), nIxyz*nTstep, fp);
        fclose( fp );  
    }
    else{
        printf("ERROR: unable to save to %s\n", filenm);
        exit(1);
    }

    /*CLEAN UP*/
    for(i=0;i<nDets;i++) {
        free(detLoc[i]);
        free(detPos[i]);
    }
    free(detLoc);
    free(detPos);
    for( i=0; i<nxstep; i++ ) {
        for( j=0; j<nystep; j++ ) {
            free(tissueType[i][j]);
        }
        free(tissueType[i]);
    }
    free(tissueType);
    free(II);

    return 0;
}


/* ------------------------------------------------------------------------- */
void tmc_error(int id,const char *msg,const char *fname,const int linenum){
    fprintf(stderr,"tMCimg ERROR(%d):%s in %s:%d\n",id,msg,fname,linenum);
    exit(id);
}


/* ------------------------------------------------------------------------- */
void tmc_assert(int ret,const char *fname,const int linenum){
    if(ret) tmc_error(ret,"assert error",fname,linenum);
}



/* ------------------------------------------------------------------------- */
int fgetl(FILE* fp, char* line, int size)
{
	int i = 0;
	int c = 0;

	/* Skip newline at beginning of line */
	c = fgetc(fp);
	if(c!='\n')
		ungetc(c, fp);

	do {
		c = fgetc(fp);

		if(c=='\r')
			continue;
		if(c=='\n') {
			line[i]=0;
			break;
		}
		if(i>=size)
			return 1;
		if(c==EOF)
			return 1;

		line[i++] = c;

	} while(1);

	return 0;
}

