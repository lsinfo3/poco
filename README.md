Pareto Optimal Controller Placement (POCO)
==========================================

A Matlab-based tool for calculating pareto-optimal placements of controllers in a network topology.

The findings of the evaluations done with POCO have been published in the paper **"Pareto-Optimal Resilient Controller Placement in SDN-based Core Networks"** by David Hock, Matthias Hartmann, Steffen Gebert, Michael Jarschel, Thomas Zinner, Phuoc Tran-Gia from the University of Wuerzburg, Germany


Paper Abstract
--------------
With the introduction of [Software Defined Networking (SDN)](http://en.wikipedia.org/wiki/Software-defined_networking), the concept of an external and optionally centralized network control plane, i.e. controller, is drawing the attention of researchers and industry. A particularly important task in the SDN context is the placement of such external resources in the network. In this paper, we discuss important aspects of the controller placement problem with a focus on SDN-based core networks, including different types of resilience and failure tolerance. When several performance and resilience metrics are considered, there is usually no single best controller placement solution, but a trade-off between these metrics. We introduce our framework for resilient *Pareto-based Optimal COntroller placement (POCO)* that provides the operator of a network with all [Pareto-optimal](http://en.wikipedia.org/wiki/Pareto_optimality) placements. The ideas and mechanisms are illustrated using the [Internet2 OS3E topology](http://www.internet2.edu/network/ose/) and further evaluated on more than 140 topologies of the [Topology Zoo](http://www.topology-zoo.org/). In particular, our findings reveal that for most of the topologies more than 20% of all nodes need to be controllers to assure a continuous connection of all nodes to one of the controllers in any arbitrary double link or node failure scenario.

About POCO
------------------
Using POCO requires MATLAB. We have tested it successfully with Matlab 2007a to 2012b. For Matlab 2013a and later, we recently introduced some compatibilty fixes, however cannot guarantee full functionality, yet.

For instructions on how to use POCO, see the [docs/plotExample.html](http://htmlpreview.github.io/?https://github.com/lsinfo3/poco/blob/master/docs/plotExample.html) file.

Authors
-------
All authors are staff members at the [Chair of Communication Networks](http://www3.informatik.uni-wuerzburg.de) at the [University of Wuerzburg, Germany](http://www.uni-wuerzburg.de):

* [David Hock](http://www3.informatik.uni-wuerzburg.de/staff/david.hock/)
* [Matthias Hartmann](http://www3.informatik.uni-wuerzburg.de/staff/hartmann/)
* [Steffen Gebert](http://www3.informatik.uni-wuerzburg.de/staff/steffen.gebert/)
* [Michael Jarschel](http://www3.informatik.uni-wuerzburg.de/staff/michael.jarschel/)
* [Dr. Thomas Zinner](http://www3.informatik.uni-wuerzburg.de/staff/zinner/)
* [Prof. Dr.-Ing. Phuoc Tran-Gia](http://www3.informatik.uni-wuerzburg.de/staff/trangia/)

License
-------

This software is licensed under the [GNU General Public License (GPL)](http://www.gnu.org/licenses/gpl.html) version 3 or later.

Acknowledgements
----------------

This work has been performed in the framework of the CELTIC EUREKA project [SASER-SIEGFRIED](http://www.celtic-initiative.org/Projects/Celtic-Plus-Projects/2011/SASER/SASER-b-Siegfried/saser-b-default.asp) (Project ID CPP2011/2-5), and it is partly funded by the [BMBF](http://www.bmbf.de/en/) (Project ID 16BP12308). The authors alone are responsible for the content of the paper.
