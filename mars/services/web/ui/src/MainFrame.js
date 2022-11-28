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

import ChevronLeftIcon from '@mui/icons-material/ChevronLeft';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import AppBar from '@mui/material/AppBar';
import Container from '@mui/material/Container';
import CssBaseline from '@mui/material/CssBaseline';
import Divider from '@mui/material/Divider';
import Drawer from '@mui/material/Drawer';
import IconButton from '@mui/material/IconButton';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import clsx from 'clsx';
import React from 'react';
import {
  HashRouter,
} from 'react-router-dom';

import LeftMenu from './LeftMenu';
import PageRouter from './PageRouter';
import {useStyles} from './Style';

export default function MainFrame() {
  const classes = useStyles();
  const [open, setOpen] = React.useState(true);
  const handleDrawerStateChange = () => {
    setOpen(!open);
  };

  return (
    <div className={classes.root}>
      <CssBaseline />
      <AppBar position="absolute" className={classes.appBar}>
        <Toolbar className={classes.toolbar}>
          <Typography component="h1" variant="h6" color="inherit" noWrap className={classes.title}>
            Mars UI
          </Typography>
        </Toolbar>
      </AppBar>
      <HashRouter>
        <Drawer
          variant="permanent"
          classes={{
            paper: clsx(classes.drawerPaper, !open && classes.drawerPaperClose),
          }}
          open={open}
        >
          <div className={classes.toolbarIcon} />
          <LeftMenu />
          <Divider className={classes.leftMenuBottomItem} />
          <div className={`${classes.toolbarIcon} ${classes.leftMenuBottomItem}`}>
            <IconButton onClick={handleDrawerStateChange} size="large">
              {open? <ChevronLeftIcon /> : <ChevronRightIcon />}
            </IconButton>
          </div>
        </Drawer>
        <main className={classes.content}>
          <div className={classes.appBarSpacer} />
          <Container maxWidth="lg" className={classes.container}>
            <PageRouter />
          </Container>
        </main>
      </HashRouter>
    </div>
  );
}
