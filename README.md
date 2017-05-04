Pareto Optimal Controller Placement (POCO)
==========================================

A Matlab-based tool for calculating pareto-optimal placements of controllers in a network topology.

![POCO Screenshot](https://raw.githubusercontent.com/lsinfo3/poco/master/images/screenshot_poco.png)


Theoretical Research Paper
--------------------------
The findings of the evaluations done with POCO have been published in the paper [Pareto-Optimal Resilient Controller Placement in SDN-based Core Networks](http://www3.informatik.uni-wuerzburg.de/staff/zinner/preprints/POCO%20ITC.pdf) by David Hock, Matthias Hartmann, Steffen Gebert, Michael Jarschel, Thomas Zinner, Phuoc Tran-Gia from the University of Wuerzburg, Germany

With the introduction of [Software Defined Networking (SDN)](http://en.wikipedia.org/wiki/Software-defined_networking), the concept of an external and optionally centralized network control plane, i.e. controller, is drawing the attention of researchers and industry. A particularly important task in the SDN context is the placement of such external resources in the network. In this paper, we discuss important aspects of the controller placement problem with a focus on SDN-based core networks, including different types of resilience and failure tolerance. When several performance and resilience metrics are considered, there is usually no single best controller placement solution, but a trade-off between these metrics. We introduce our framework for resilient *Pareto-based Optimal COntroller placement (POCO)* that provides the operator of a network with all [Pareto-optimal](http://en.wikipedia.org/wiki/Pareto_optimality) placements. The ideas and mechanisms are illustrated using the [Internet2 OS3E topology](http://www.internet2.edu/network/ose/) and further evaluated on more than 140 topologies of the [Topology Zoo](http://www.topology-zoo.org/). In particular, our findings reveal that for most of the topologies more than 20% of all nodes need to be controllers to assure a continuous connection of all nodes to one of the controllers in any arbitrary double link or node failure scenario.

Demo Papers
-----------
POCO has been demonstrated at the following conferences:

  * ACM SIGCOMM, Chicago, USA, August 2014: [Demonstrating the Optimal Placement of Virtualized Cellular Network Functions in Case of Large Crowd Events
](http://www3.informatik.uni-wuerzburg.de/staff/zinner/preprints/Demo%20POCO%20SIGCOMM.pdf)
  * IEEE/IFIP Network Operations and Management Symposium (NOMS), Krakow, Poland, May 2014: [POCO: A Framework for the Pareto-Optimal Resilient Controller Placement in SDN-based Core Networks.](http://www3.informatik.uni-wuerzburg.de/research/projects/saser/poco/publications/pocodemo_ieee_noms.pdf)
  * IEEE International Conference on Computer Communications (INFOCOM), Toronto, Canada, April 2014: [POCO-PLC: Enabling Dynamic Pareto-Optimal Resilient Controller Placement in SDN Networks.](http://www3.informatik.uni-wuerzburg.de/research/projects/saser/poco/publications/pocodemo_ieee_info.pdf)

POCO PLC
--------
In order to use POCO PLC, proceed according to the following steps.
  * Extract the [localbackup folder](http://euros.informatik.uni-wuerzburg.de/public/localbackup.zip) to your POCO root folder (i.e., the localbackup folder should be in the same folder as poco_GUI.m). Each of these CSV files contains RTT-values for each pair of nodes in the planetlabV2.topo.mat topology for a given timestamp.
  * Start POCO by running poco_GUI in MATLAB.
  * You can cancel the topology selection step.
  * In the menu, click POCO PLC -> Start POCO PLC.
  * In the menu, click Placements -> Calculate placements -> Failure free -> k = ...
  * In the Pareto-plot, click on a placement in order to activate it.
  * In the menu, click POCO PLC -> Start Planetlab Plot Loop.

In order to get started with custom PLC scenarios, check the PLCPlotLoop function in poco_GUI.m and adapt the code in the code/*PLC.m files.

Authors
-------
All authors are staff members at the [Chair of Communication Networks](http://www3.informatik.uni-wuerzburg.de) at the [University of Wuerzburg, Germany](http://www.uni-wuerzburg.de):

* Dr. David Hock
* Dr. Matthias Hartmann
* [Steffen Gebert](http://www3.informatik.uni-wuerzburg.de/staff/steffen.gebert/)
* [Stanislav Lange](http://www3.informatik.uni-wuerzburg.de/staff/stanislav.lange/)
* Dr. Michael Jarschel
* [Dr. Thomas Zinner](http://www3.informatik.uni-wuerzburg.de/staff/zinner/)
* [Prof. Dr.-Ing. Phuoc Tran-Gia](http://www3.informatik.uni-wuerzburg.de/staff/trangia/)


Acknowledgments
---------------
This work has been performed in the framework of the CELTIC EUREKA project [SASER-SIEGFRIED](http://saser.eu) (Project ID CPP2011/2-5), and it is partly funded by the BMBF (Project ID 16BP12308). The authors alone are responsible for the content of the paper.

![SASER](http://saser-siegfried.eu/fileadmin/content/saser/logos/saser/logo-hero.png)


Compatibility
-------------
Using POCO requires MATLAB. We have tested it successfully with Matlab 2007a to 2014a.


License
-------
This software is licensed under the [GNU General Public License (GPL)](http://www.gnu.org/licenses/gpl.html) version 3 or later.