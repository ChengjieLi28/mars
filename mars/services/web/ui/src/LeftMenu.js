/*
 * Copyright 1999-2021 Alibaba Group Holding Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import AssignmentReturnedIcon from '@mui/icons-material/AssignmentReturned';
import DashboardIcon from '@mui/icons-material/Dashboard';
import DescriptionIcon from '@mui/icons-material/Description';
import GitHub from '@mui/icons-material/GitHub';
import MemoryIcon from '@mui/icons-material/Memory';
import SupervisedUserCircleIcon from '@mui/icons-material/SupervisedUserCircle';
import Divider from '@mui/material/Divider';
import List from '@mui/material/List';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import React from 'react';
import { Link } from 'react-router-dom';

import {useStyles} from './Style';

export default function LeftMenu() {
  const classes = useStyles();
  const getHashPath = () => (window.location.hash.substring(1));
  const [hash, setHash] = React.useState(getHashPath());

  window.addEventListener('hashchange', () => {
    setHash(getHashPath());
  }, false);

  const genNodeSubMenu = (nodeRole) => {
    const match = hash.match(/^\/(supervisor|worker)\/([^/]+)/, 1);
    return (
      match && nodeRole === match[1] &&
        <React.Fragment>
          <Divider />
          <List component="div" disablePadding>
            <ListItemButton className={classes.nestedListItem}
              component={Link} to={`/${match[1]}/${match[2]}`}
              selected={true}
            >
              <ListItemIcon />
              <ListItemText primary={match[2]} />
            </ListItemButton>
          </List>
        </React.Fragment>
    );
  };

  const genSessionSubMenu = () => {
    const match = hash.match(/^\/session\/([^/]+)\/task/, 1);
    return (
      match &&
        <React.Fragment>
          <Divider />
          <List component="div" disablePadding>
            <ListItemButton className={classes.nestedListItem}
              component={Link} to={`/session/${match[1]}/task`}
              selected={true}
            >
              <ListItemIcon />
              <ListItemText primary={match[1]} />
            </ListItemButton>
          </List>
        </React.Fragment>
    );
  };

  return (
    <List className={classes.leftMenu}>
      <div>
        <ListItemButton component={Link} to="/" selected={hash === '/'}>
          <ListItemIcon>
            <DashboardIcon />
          </ListItemIcon>
          <ListItemText primary="Dashboard" />
        </ListItemButton>
        <ListItemButton component={Link} to="/supervisor"
          selected={hash.startsWith('/supervisor')}
        >
          <ListItemIcon>
            <SupervisedUserCircleIcon />
          </ListItemIcon>
          <ListItemText primary="Supervisors" />
        </ListItemButton>
        {genNodeSubMenu('supervisor')}
        <ListItemButton component={Link} to="/worker"
          selected={hash.startsWith('/worker')}
        >
          <ListItemIcon>
            <MemoryIcon />
          </ListItemIcon>
          <ListItemText primary="Workers" />
        </ListItemButton>
        {genNodeSubMenu('worker')}
        <ListItemButton component={Link} to="/session"
          selected={hash === '/session'}
        >
          <ListItemIcon>
            <AssignmentReturnedIcon />
          </ListItemIcon>
          <ListItemText primary="Sessions" />
        </ListItemButton>
        {genSessionSubMenu()}
        <ListItemButton component="a" href="https://docs.pymars.org" target="_blank">
          <ListItemIcon>
            <DescriptionIcon />
          </ListItemIcon>
          <ListItemText primary="Documentation" />
        </ListItemButton>
        <ListItemButton component="a" href="https://github.com/mars-project/mars" target="_blank">
          <ListItemIcon>
            <GitHub />
          </ListItemIcon>
          <ListItemText primary="Repository" />
        </ListItemButton>
      </div>
    </List>
  );
}
