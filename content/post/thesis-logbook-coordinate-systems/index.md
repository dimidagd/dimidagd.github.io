---
title: Coordinate systems
summary: "Archived note on geodetic, ENU, ECEF, body, seakeeping, and tracking coordinate systems."
authors:
  - admin
tags:
  - Archive
  - Tracking
  - Coordinate systems
  - Thesis logbook
categories:
  - Engineering
  - Archive
date: '2020-02-19T16:16:09+01:00'
lastmod: '2020-02-19T16:16:09+01:00'
draft: false
featured: false
math: true
aliases:
  - /thesis/logbook/coordinate_systems/
---
<!-- TOC -->

  - [Earth coordinate systems](#earth-coordinate-systems)
    - [Geodetic coordinates](#geodetic-coordinates)
    - [Local-tangential - ENU](#local-tangential---enu)
    - [Earth Centered Earth-fixed (ECEF)](#earth-centered-earth-fixed-ecef)
    - [Transformations](#transformations)
      - [Geodetic to ECEF](#geodetic-to-ecef)
      - [ECEF to ENU](#ecef-to-enu)
  - [Ship coordinate systems](#ship-coordinate-systems)
    - [Body fixed coordinate system](#body-fixed-coordinate-system)
    - [Seakeeping coordinate system](#seakeeping-coordinate-system)
    - [Tracking coordinates system](#tracking-coordinates-system)
    - [Purpose of using different coordinate systems](#purpose-of-using-different-coordinate-systems)
    - [Transformations](#transformations-1)
      - [From ENU to tracking coordinates](#from-enu-to-tracking-coordinates)
    - [Purpose of using different coordinate systems](#purpose-of-using-different-coordinate-systems-1)

<!-- /TOC -->


# Earth coordinate systems

When defining the configuration space, four coordinate systems are usually involved in _target tracking_ algorithms.

* Geodetic
* Local-tangential East-North-Up (ENU)
* Earth-Centered Earth-fixed (ECEF)

The transformations between the systems exist and are non-linear.

#### Geodetic coordinates

The earth's surface is approximated by an ellipsoid of revolution of known parameters. The parameters depend on the datum of choice. In the scope of this chapter, the selected datum is the ***WGS 84***. Locations near the surface are described in terms of latitude, longitude, and height $(\phi, \lambda, h)^T$.

{{< figure src="/thesis/geodetic.png" title="Geodetic coordinate system" width="50%">}}

#### Local-tangential - ENU

The local tangential plane coordinates, are based on the local _vertical direction_ and the earth's axis of rotation.

Two variants exist, the selection of which is a matter of convention but leads to slightly different state vectors in tracking applications.

  - East, North, Up (***ENU***)
  - North, East, Down (***NED***)

The local-tangential ***east-north-up***  plane is the rectangular coordinate system determined by _fitting a tangential plane_ to the surface of the earth at some reference point $[X_0,Y_0,Z_0]$. The reference point is the origin of the frame.

*Such a system is convenient in the context of tracking nearby ships because the tracking problem can be reduced to tracking a target on a two-dimensional plane*.






#### Earth Centered Earth-fixed (ECEF)

**ECEF** is a _cartesian coordinate system_ $[X,Y,Z]^T$ with its origin placed at the earth's _center of mass_, hence the naming convention. It is a rotating system as the _z-axis_ is pointing through _true north_ and the x-axis intersects the earth's sphere at $[\phi,\lambda]^{T} =  [0,0]^{T}$.

{{< figure src="/thesis/ECEF_ENU.png" title="ECEF and ENU systems" width="50%">}}

## Transformations


There is a need to define transformations between different coordinate systems.
#### Geodetic to ECEF

GPS measurements usually arrive in ***geodetic*** coordinates, where as tracking is usually performed in the ***local tangential*** plane of the own-ship.

The transformation between these two systems requires an intermediate transformation from ***geodetic*** $(\phi,\lambda,h)$ to ***ECEF***   $(X,Y,Z)$ coordinates.




$$\begin{align*}
X &=(N+h)cos\lambda cos\phi \\\\
Y &= (N+h)cos\lambda sin\phi \\\\
Z &= [N(1-e^2)+h] sin\lambda
\end{align*}$$

#### ECEF to ENU




Given a reference point in Geodetic $[\phi_0,\lambda_0]$ and the corresponding ECEF $[X_0,Y_0,Z_0]$ coordinates, then any other point's ECEF coordinates $[X,Y,Z]$ can be converted to local tangential plane coordinates $[x,y,z]$ using the following transformation


$$
\begin{bmatrix}
x\\
y\\
z
\end{bmatrix}= \mathcal{L}\left(\begin{bmatrix}
X\\
Y\\
Z
\end{bmatrix} - \begin{bmatrix}
X_0\\
Y_0\\
Z_0
\end{bmatrix}\right)
$$

where $\mathcal{L}$ is a function of the reference point $[\phi_0,\lambda_0,h_0]$

$$
\mathcal{L} = \begin{bmatrix}
-sin\phi_0  & cos\phi_0 & 0 \\\\
-sin\lambda_0cos\phi_0 & -sin\lambda_0sin\phi_0 & cos\lambda_0\\\\
cos\lambda_0 cos\phi_0 & cos\lambda_0 sin\phi_0 & sin\lambda_0
\end{bmatrix}
$$


# Ship coordinate systems

To describe the position and orientation of a ship, one can use the following orthogonal coordinate systems:

- NED/ENU, $\\{n\\} , \\{e\\}$
- Body-fixed, $\\{b\\}$
- Seakeeping, $\\{s\\}$
- Tracking coordinates, $\\{t\\}$

{{< figure src="/thesis/seakeeping_body.jpg" title="Body fixed sea-keeping and NED systems" width="50%">}}
src: [[Kinematic Models for Manoeuvring and Seakeeping of Marine Vessels](https://www.researchgate.net/publication/41719906_Kinematic_Models_for_Manoeuvring_and_Seakeeping_of_Marine_Vessels)]


#### Body fixed coordinate system

This system is fixed to the hull of a vessel. The x-axis pointing towards the bow, y-axis point starboard and z-axis pointing downwards completing the orthogonal system. The origin of the system is usually the origin of the principal axes of inertia, which simplifies the solution of the dynamical equations of motion for the body.

#### Seakeeping coordinate system

The ***seakeeping*** frame follows the average speed of the vessel. As such, the system is fixed to the ship's _equilibrium_ state, which is defined by the average speed and heading. The positive x-axis is pointing towards the forward velocity vector, the y-axis pointing starboard and the z-axis pointing down. The origin of the system is selected so that the z-axis is pointing through its mean center of mass, and the x-y plane coincides with the mean free water surface.

#### Tracking coordinates system

For the shake of simplicity, one can define the tracking coordinates system $\\{t\\}$. The origin of the tracking system coincides with the origin of the seakeeping coordinate system of the own-ship. The x-axis is pointing in the heading direction of the own-ship, the y-axis is pointing port, and the z-axis up to complete a dextral orthogonal system. The x-y axes are always coplanar to the East North plane and since this is an ***equilibrium coordinate system***, the coordinates of a tracked target in this system do not depend on the roll or pitch angles of the own-ship. Thus the configuration space for the tracking problem is reduced in tracking along two dimensions.


{{< figure src="/thesis/coords.png" title="ENU and own-ship tracking coordinates" width="50%">}}


### Purpose of using different coordinate systems


Both the motion and the measurement model equations depend on the coordinate system of choice. Sensor measurements from a radar usually arrive in the sensor's local spherical system, where as the GPS measurements either for the own-ship or for other vessels arrive in the geodetic system. It is convenient to consider that all floating targets move on the same plane, thus to express a target's motion model w.r.t the own-ship's local tangential plane.

Since the local sensors like the radar and the cameras are rigidly attached to the body-frame, it is important to consider the transformations from the body coordinate system to the own-ship's equilibrium coordinate system.



<!--

This frame is the local-tangential frame rotated around the z-axis so that the x-axis is aligned with the own-ships heading direction from the true north $h_{self_{true}}$. This frame in case of a non rolling-pitching vessel coincides with the body-fixed frame. This is also called the sea-keeping frame because the vessel is assumed to move along the direction of its average velocity. Since this system is rotating along the vessel's heading direction and so do the local sensors, it is convenient to use for tracking purposes.
-->

### Transformations

#### From ENU to tracking coordinates

If the origin of the ENU system is selected to coincide with the origin of the own-ship's tracking coordinates origin, and $\psi$ is the heading angle of the own-ship from the North direction, then the transformation from ENU, to the own-ship's tracking coordinates is





$$\begin{bmatrix}
x \\\\
y \\\\
z
\end{bmatrix}\_{\text{{t}}} = R_{z}(\frac{\pi}{2}-\psi)
\begin{bmatrix}
E \\\\
N \\\\
U
\end{bmatrix}_{\text{{e}}}
$$

where

$$
R_{z}(\theta)=\begin{bmatrix}
cos\theta &-sin\theta &0\\\\
sin\theta &cos\theta &0 \\\\
0 &0 &1
\end{bmatrix}
$$







## Purpose of using different coordinate systems


Both the _motion_ and the _measurement_ model equations depend on the coordinate system of choice.

Sensor measurements from a radar usually arrive in the local tangential system, where as the GPS measurements either for the own-ship or for other vessels arrive in the geodetic system.

It is convenient thus to express a ***target's motion model*** w.r.t the ***local tangential & body fixed frame***, since the local sensors like the radar and the cameras are rigidly attached to the body-frame.

This simplifies the measurement models for local sensors, nevertheless working in the local tangential plane induces errors when one has to use models that depend on the ***earth's curvature*** like the **AIS**.
